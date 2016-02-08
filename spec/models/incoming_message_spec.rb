require 'rails_helper'

describe IncomingMessage do

  let(:text)     { Faker::Name.name }
  let(:channel)  { create(:channel) }
  let(:user)     { create(:user) }
  let!(:setting) { create(:setting, name: channel.name) }

  let(:message) do
    { channel: channel.slack_id, user: user.slack_id, text: text }.with_indifferent_access
  end

  subject { described_class.new(message) }

  before do
    allow_any_instance_of(Channel).to receive(:slack_client).and_return(double(:web_client).as_null_object)

    channel.users << user
  end

  describe '#execute' do
    context 'when standup does not exist' do
      context 'and given the start command' do
        let(:text) { '-start' }

        it 'creates a new standup session' do
          expect { subject.execute }.to change { Standup.count }.by(1)
        end

        it 'creates a job to auto skip current user if needed' do
          expect_any_instance_of(described_class::AutoSkip).to receive(:perform)

          subject.execute
        end
      end

      context 'and given the help command' do
        let(:text) { '-help' }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end
      end

      context 'and given the vacation command' do
        let(:text) { "-vacation: <@#{user.slack_id}>" }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not set given user on vacation' do
          expect_any_instance_of(Standup).to_not receive(:vacation!)

          subject.execute
        end
      end

      context 'and given the skip command' do
        let(:text) { '-skip' }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not change the state of given user' do
          expect_any_instance_of(Standup).to_not receive(:skip!)

          subject.execute
        end
      end

      context 'and given the quit command' do
        let(:text) { '-quit' }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not change the status to done' do
          subject.execute

          expect(subject.standup_finished?).to be_falsey
        end
      end

      context 'and given the yes command' do
        let(:text) { '-yes' }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not change the state of given user to answering' do
          expect_any_instance_of(Standup).to_not receive(:start!)

          subject.execute
        end
      end

      context 'and given the delete command' do
        let(:text) { '-delete: 1' }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not delete given user\'s answer' do
          expect_any_instance_of(Standup).to_not receive(:delete_answer_for).with(1)

          subject.execute
        end
      end

      context 'and given the postpone command (skip @user)' do
        let(:text) { "-skip: <@#{user.slack_id}>" }

        it 'does not create any new messages' do
          expect_any_instance_of(Channel).to_not receive(:message)

          subject.execute
        end

        it 'does not change the state of given user' do
          expect_any_instance_of(Standup).to_not receive(:skip!)

          subject.execute
        end
      end
    end

    context 'when standup exists' do
      let!(:standup) { create(:standup, user_id: user.id, channel_id: channel.id) }

      context 'and given the start command' do
        let(:text) { '-start' }

        it 'does not create a new standup session' do
          expect { subject.execute }.to_not change { Standup.count }
        end

        it 'does not create a job to auto skip current user if needed' do
          expect_any_instance_of(described_class::AutoSkip).to_not receive(:perform)

          subject.execute
        end
      end

      context 'and given the help command' do
        let(:text) { '-help' }

        it 'creates a new message with the expected parameters' do
          expect_any_instance_of(Channel).to receive(:message).
            with(I18n.t('incoming_message.help'))

          subject.execute
        end
      end

      context 'and answering the last question of all the standups' do
        let(:text) { 'nope' }

        before do
          standup.state= Standup::ANSWERING
          standup.yesterday= 'Worked on several things'
          standup.today= 'Finished all the tasks that I was working yesterday'
          standup.save
        end

        it 'sends a report email' do
          expect(StandupMailer).to receive(:today_report).with(channel.id).and_return(double(:mailer).as_null_object)

          subject.execute
        end
      end

      context 'and given the skip command' do
        let(:text) { '-skip' }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not change its state' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_attributes(state: Standup::ACTIVE, order: 1) }

          it 'does not create a job to auto skip current user' do
            expect_any_instance_of(described_class::AutoSkip).to_not receive(:perform)

            subject.execute
          end

          context 'and there is another standup waiting to answer its questions' do
            let!(:standup_2) { create(:standup, state: Standup::IDLE, channel_id: channel.id, order: 2) }

            before { channel.users << standup_2.user }

            it 'creates a job to auto skip current user if needed' do
              expect_any_instance_of(described_class::AutoSkip).to receive(:perform)

              subject.execute
            end

            it 'changes its state to IDLE back' do
              expect { subject.execute }.to change { standup.reload.state }.to(Standup::IDLE)
            end
          end

          context 'and its the last active standup' do
            it 'keeps its state as active' do
              expect { subject.execute }.to_not change { standup.reload.state }
            end
          end
        end
      end

      context 'and given the edit command' do
        let(:text) { '-edit: 1' }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not update the standup tuple' do
            expect { subject.execute }.to_not change { standup.reload.updated_at }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_column(:state, Standup::ACTIVE) }

          it 'does not update the standup tuple' do
            expect { subject.execute }.to_not change { standup.reload.updated_at }
          end
        end

        context 'for an ANSWERING standup' do
          before do
            standup.update_attributes(state: Standup::ANSWERING, yesterday: 'something')
          end

          it 'removes the content of given answer' do
            expect { subject.execute }.to change { standup.reload.yesterday }.to(nil)
          end
        end

        context 'for a DONE standup' do
          before do
            standup.update_attributes(state: Standup::DONE, yesterday: 'something')
          end

          it 'removes the content of given answer' do
            expect { subject.execute }.to change { standup.reload.yesterday }.to(nil)
          end

          it 'changes its state to ANSWERING back' do
            expect { subject.execute }.to change { standup.reload.state }.to(Standup::ANSWERING)
          end
        end
      end

      context 'and given the delete command' do
        let(:text) { '-delete: 1' }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not update the standup tuple' do
            expect { subject.execute }.to_not change { standup.reload.updated_at }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_column(:state, Standup::ACTIVE) }

          it 'does not update the standup tuple' do
            expect { subject.execute }.to_not change { standup.reload.updated_at }
          end
        end

        context 'for an ANSWERING standup' do
          before do
            standup.update_attributes(state: Standup::ANSWERING, yesterday: 'something')
          end

          it 'removes the content of given answer' do
            expect { subject.execute }.to change { standup.reload.yesterday }.to(nil)
          end
        end

        context 'for a DONE standup' do
          before do
            standup.update_attributes(state: Standup::DONE, yesterday: 'something')
          end

          it 'removes the content of given answer' do
            expect { subject.execute }.to change { standup.reload.yesterday }.to(nil)
          end

          it 'does not change its state back to ANSWERING' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end
      end

      context 'and given the vacation command' do
        let(:text) { "-vacation: <@#{user.slack_id}>" }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not set the user on vacation' do
            subject.execute

            expect(standup.reload.vacation?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_column(:state, Standup::ACTIVE) }

          context 'and current user is not an admin' do
            before { user.update_column(:admin, false) }

            it 'does not set the user on vacation' do
              subject.execute

              expect(standup.reload.vacation?).to be_falsey
            end

            it 'does not change its state to DONE' do
              expect { subject.execute }.to_not change { standup.reload.state }
            end
          end

          context 'and current user is the admin' do
            before { user.update_column(:admin, true) }

            it 'sets the user on vacation' do
              subject.execute

              expect(standup.reload.vacation?).to be_truthy
            end

            context 'and there are other standups waiting to answer its questions' do
              let!(:standup_2) { create(:standup, state: Standup::IDLE, channel_id: channel.id, order: 2) }

              before { channel.users << standup_2.user }

              it 'creates a job to auto skip current user if needed' do
                expect_any_instance_of(described_class::AutoSkip).to receive(:perform)

                subject.execute
              end
            end
          end
        end

        context 'for an ANSWERING standup' do
          before do
            standup.update_attributes(state: Standup::ANSWERING, yesterday: 'something')
          end

          it 'does not set the user on vacation' do
            subject.execute

            expect(standup.reload.vacation?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for a DONE standup' do
          before do
            standup.update_attributes(state: Standup::DONE, yesterday: 'something')
          end

          it 'does not set the user on vacation' do
            subject.execute

            expect(standup.reload.vacation?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end
      end

      context 'and given the not available command' do
        let(:text) { "-n/a: <@#{user.slack_id}>" }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not set the user to not available' do
            subject.execute

            expect(standup.reload.not_available?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_column(:state, Standup::ACTIVE) }

          context 'and current user is not the admin' do
            before { user.update_column(:admin, false) }

            it 'does not set the user to not available' do
              subject.execute

              expect(standup.reload.not_available?).to be_falsey
            end

            it 'does not change its state to DONE' do
              expect { subject.execute }.to_not change { standup.reload.state }
            end
          end

          context 'and current user is the admin' do
            before { user.update_column(:admin, true) }

            context 'and there are other standups waiting to answer its questions' do
              let!(:standup_2) { create(:standup, state: Standup::IDLE, channel_id: channel.id, order: 2) }

              before { channel.users << standup_2.user }

              it 'creates a job to auto skip current user if needed' do
                expect_any_instance_of(described_class::AutoSkip).to receive(:perform)

                subject.execute
              end
            end

            it 'sets the user to not available' do
              subject.execute

              expect(standup.reload.not_available?).to be_truthy
            end
          end
        end

        context 'for an ANSWERING standup' do
          before { standup.update_attributes(state: Standup::ANSWERING) }

          it 'does not set the user to not available' do
            subject.execute

            expect(standup.reload.not_available?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for a DONE standup' do
          before { standup.update_attributes(state: Standup::DONE) }

          it 'does not set the user to not available' do
            subject.execute

            expect(standup.reload.not_available?).to be_falsey
          end

          it 'does not change its state to DONE' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end
      end

      context 'and given the skip command' do
        let(:text) { "-skip: <@#{user.slack_id}>" }

        context 'for an IDLE standup' do
          before { standup.update_column(:state, Standup::IDLE) }

          it 'does not change the standup state' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for an ACTIVE standup' do
          before { standup.update_column(:state, Standup::ACTIVE) }

          context 'and current user is not the admin' do
            before { user.update_column(:admin, false) }

            it 'does not change the standup state' do
              expect { subject.execute }.to_not change { standup.reload.state }
            end
          end

          context 'and current user is the admin' do
            before { user.update_column(:admin, true) }

            context 'and there are other standups waiting to answer its questions' do
              let!(:standup_2) { create(:standup, state: Standup::IDLE, channel_id: channel.id, order: 2) }

              before { channel.users << standup_2.user }

              it 'creates a job to auto skip current user if needed' do
                expect_any_instance_of(described_class::AutoSkip).to receive(:perform)

                subject.execute
              end

              it 'changes the standup state back to IDLE' do
                expect { subject.execute }.to change { standup.reload.state }.to(Standup::IDLE)
              end
            end
          end
        end

        context 'for an ANSWERING standup' do
          before { standup.update_attributes(state: Standup::ANSWERING) }

          it 'does not change the standup state' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end

        context 'for a DONE standup' do
          before { standup.update_attributes(state: Standup::DONE) }

          it 'does not change the standup state' do
            expect { subject.execute }.to_not change { standup.reload.state }
          end
        end
      end

      context 'and given the quit command' do
        let(:text) { '-quit-standup' }

        it 'changes the status to done' do
          subject.execute

          expect(subject.standup_finished?).to be_truthy
        end
      end
    end
  end

end
