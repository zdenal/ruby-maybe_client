require_relative '../lib/maybe_client'
require 'timecop'

describe MaybeClient do
  let(:client_class) { double('client class') }
  let(:connect_params) { 'connect params can be string or hash or anything' }
  let(:client) { double('client') }
  let(:result) { double('result') }

  context 'initializing the client inside' do

    let(:maybe_client) { MaybeClient.new(client_class: client_class, connect_params: connect_params) }

    describe '#method_missing' do

      context 'backend is online' do
        before do
          allow(client_class).to receive(:new)
            .with(connect_params)
            .and_return(client)
        end

        it {
          expect(client).to receive(:foo).with(1, 2, 3).and_return(result)
          expect(maybe_client.foo(1, 2, 3)).to eql result
        }

        context 'but backend dies later' do
          it {
            allow(maybe_client).to receive(:exception_handler)
            expect(client).to receive(:foo).with(1, 2, 3).and_raise(Exception)

            expect(maybe_client.foo(1, 2, 3)).to eql nil
            expect(maybe_client).to have_received(:exception_handler).once
          }
        end
      end

      context 'backend is offline' do
        before do
          allow(client_class).to receive(:new)
            .with(connect_params)
            .and_raise(Exception)

          maybe_client
        end

        it {
          expect(client).to receive(:foo).never
          expect(maybe_client.foo(1, 2, 3)).to eql nil
        }

        context 'but backend comes alive later' do
          before do
            allow(client_class).to receive(:new)
              .with(connect_params)
              .and_return(client)
          end

          context 'before delay runs out' do
            it {
              expect(client).to receive(:foo).never
              expect(maybe_client.foo(1, 2, 3)).to eql nil
            }
          end

          context 'after delay runs out' do
            before do
              Timecop.travel(Time.now + MaybeClient::DELAY)
            end

            after do
              Timecop.return
            end

            it {
              expect(client).to receive(:foo).with(1, 2, 3).and_return(result)
              expect(maybe_client.foo(1, 2, 3)).to eql result
            }
          end
        end
      end

    end
  end

  context 'getting the client from outside' do

    let(:maybe_client) { MaybeClient.new(client: client) }

    describe '#method_missing' do

      context 'backend is online' do
        it {
          expect(client).to receive(:foo).with(1, 2, 3).and_return(result)
          expect(maybe_client.foo(1, 2, 3)).to eql result
        }

        context 'but backend dies later' do
          it {
            allow(maybe_client).to receive(:exception_handler)
            expect(client).to receive(:foo).with(1, 2, 3).and_raise(Exception)

            expect(maybe_client.foo(1, 2, 3)).to eql nil
            expect(maybe_client).to have_received(:exception_handler).once
          }
        end
      end

      context 'backend is offline' do
        after do
          Timecop.return
        end

        it {
          expect(client).to receive(:foo).with(1, 2, 3).and_raise(Exception)
          expect(maybe_client.foo(1, 2, 3)).to eql nil

          # Before delay
          expect(client).to receive(:foo).never
          expect(maybe_client.foo(1, 2, 3)).to eql nil

          # After delay
          Timecop.travel(Time.now + MaybeClient::DELAY)
          RSpec::Mocks.space.proxy_for(client).reset
          expect(client).to receive(:foo).with(1, 2, 3).and_return(result)
          expect(maybe_client.foo(1, 2, 3)).to eql result
        }
      end

    end
  end

  describe '#respond_to?' do
    let(:maybe_client) { MaybeClient.new(client: client) }

    before do
      allow(client).to receive(:foo)
    end

    it { expect(maybe_client.respond_to? :foo).to eql true }
    it { expect(maybe_client.respond_to? :bar).to eql false }
  end
end
