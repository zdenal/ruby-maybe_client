require_relative '../lib/maybe_client'
require 'timecop'

describe MaybeClient do
  let(:client_class) { double('client class') }
  let(:connect_params) { 'connect params can be string or hash or anything' }
  let(:client) { double('client') }
  let(:result) { double('result') }

  let(:maybe_client) { MaybeClient.new(client_class, connect_params) }

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
          expect(client).to receive(:foo).with(1, 2, 3).and_raise(Exception)
          expect(maybe_client.foo(1, 2, 3)).to eql nil
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

  describe '#respond_to?' do
    before do
      allow(client_class).to receive(:new)
        .with(connect_params)
        .and_return(client)

      allow(client).to receive(:foo)
    end

    it { expect(maybe_client.respond_to? :foo).to eql true }
    it { expect(maybe_client.respond_to? :bar).to eql false }
  end
end
