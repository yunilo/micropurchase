require 'rails_helper'

describe AuctionPresenter do
  include ActionView::Helpers::DateHelper

  let(:ar_auction) { create(:auction) }
  let(:ar_bids_by_amount) { ar_auction.bids.order('amount ASC, created_at ASC') }
  let(:auction) { AuctionPresenter.new(ar_auction) }
  let(:user) { create(:user) }

  describe '#url' do
    it 'returns a valid url that includes the id of the auction' do
      expect(auction.url).to be_url
      expect(auction.url).to include(auction.id.to_s)
    end
  end

  describe '#small_business?' do
    context 'when the start price is below the micro-purchase threshold' do
      let(:ar_auction) { create(:auction, :below_micropurchase_threshold) }

      it 'returns false' do
        expect(auction.small_business?).to be false
      end
    end

    context %(
      when the start price is above the micropurchase threshold
      but below the simplified acquisitions threshold
                                                                ) do

      let(:ar_auction) do
        create(:auction, :between_micropurchase_and_sat_threshold)
      end

      it 'returns true' do
        expect(auction.small_business?).to be true
      end
    end
  end

  describe 'internal bid methods' do
    context 'when there are no bids' do
      let(:ar_auction) { create(:auction) }

      specify { expect(auction.bids?).to be_falsey }
      specify { expect(auction.bid_count).to eq(0) }
      specify { expect(auction.bids).to eq([]) }
      specify { expect(auction.lowest_bid).to be_a(NullBidPresenter) }

      it 'max_allowed_bid should return the starting bid for the auction' do
        expect(auction.max_allowed_bid).to eq(auction.start_price - PlaceBid::BID_INCREMENT)
      end

      specify { expect(auction.lowest_bids).to eq([]) }
      specify { expect(auction.lowest_bid_amount).to be_nil }
    end

    context 'when there are multiple bids' do
      let(:ar_auction) { create(:auction, :with_bidders) }

      specify { expect(auction.bids?).to be_truthy }
      specify { expect(auction.bid_count).to eq(ar_auction.bids.count) }

      it 'bids should return BidPresenter objects sorted by descending creation time' do
        bids = auction.bids
        last_create = 100.years.from_now

        expect(bids).to be_an(Array)
        bids.each do |bid|
          expect(bid).to be_a(BidPresenter)
          expect(bid.created_at).to be <= last_create
          last_create = bid.created_at
        end
      end

      it 'lowest_bid should return the bid with the lowest amount' do
        lowest_bid = auction.lowest_bid

        expect(lowest_bid).to be_a(BidPresenter)
        expect(lowest_bid.amount).to eq(ar_bids_by_amount.first.amount)
        expect(lowest_bid.bidder_id).to eq(ar_bids_by_amount.first.bidder_id)
      end

      specify { expect(auction.max_allowed_bid).to eq(auction.lowest_bid.amount - PlaceBid::BID_INCREMENT) }

      it 'lowest_bids should return an array of the lowest amount' do
        bids = auction.lowest_bids

        expect(bids).to be_an(Array)
        expect(bids.count).to eq(1)
        expect(bids.first.bidder_id).to eq(ar_bids_by_amount.first.bidder_id)
        expect(bids.first.amount).to eq(ar_bids_by_amount.first.amount)
      end

      it 'lowest_amount should return the lowest bid' do
        expect(auction.lowest_bid_amount).to eq(ar_bids_by_amount.first.amount)
      end
    end

    context 'when there are multiple low bids of the same amount' do
      let(:ar_auction) { create(:auction, :single_bid_with_tie) }

      specify { expect(auction.bids?).to be_truthy }
      specify { expect(auction.bid_count).to eq(ar_auction.bids.count) }

      it 'bids should return BidPresenter objects sorted by descending creation time' do
        bids = auction.bids
        last_create = 100.years.from_now

        expect(bids).to be_an(Array)
        bids.each do |bid|
          expect(bid).to be_a(BidPresenter)
          expect(bid.created_at).to be <= last_create
          last_create = bid.created_at
        end
      end

      it 'lowest_bid should return the bid with the lowest amount and the earliest creation time' do
        lowest_bid = auction.lowest_bid

        expect(lowest_bid).to be_a(BidPresenter)
        expect(lowest_bid.amount).to eq(ar_bids_by_amount.first.amount)
        expect(lowest_bid.bidder_id).to eq(ar_bids_by_amount.first.bidder_id)
      end

      specify { expect(auction.max_allowed_bid).to eq(auction.start_price - PlaceBid::BID_INCREMENT) }

      it 'lowest_bids should return an array of all bids with the lowest amount sorted by ascending creation time' do
        lowest_bids = auction.lowest_bids
        ar_lowest_bids = ar_bids_by_amount.select { |b| b.amount == ar_bids_by_amount.first.amount }

        expect(lowest_bids).to be_an(Array)
        expect(lowest_bids.first).to be_a(BidPresenter)
        expect(lowest_bids.count).to eq(ar_lowest_bids.count)
        expect(lowest_bids.map(&:id)).to eq(ar_lowest_bids.map(&:id))
        expect(lowest_bids.map(&:bidder_id)).to eq(ar_lowest_bids.map(&:bidder_id))
      end
    end
  end

  describe 'type-specific bid methods' do
    context 'for a single-bid auction' do
      context 'when the auction is still running' do
        let(:ar_auction) { create(:auction, :single_bid_with_tie, :running) }

        context 'when the user has not placed a bid' do
          it 'veiled_bids should return an empty array' do
            expect(auction.veiled_bids(user)).to match_array([])
          end
        end

        context 'the user has placed a bid' do
          let(:last_bid) { auction.bids.last }
          let(:last_bidder) { last_bid.bidder }

          it 'veiled_bids should return only the bid placed by the user' do
            expect(auction.veiled_bids(last_bidder).map(&:id)).to match_array([last_bid].map(&:id))
          end
        end

        context 'when the auction has no bids' do
          it 'veiled_bids should return an empty array' do
            expect(auction.veiled_bids(user)).to match_array([])
          end
        end

        context 'when the auction is closed' do
          let(:ar_auction) { create(:auction, :single_bid_with_tie, :closed) }

          it 'veiled_bids should return all bids associated with the auction' do
            expect(auction.veiled_bids(user).map(&:id)).to match_array(auction.bids.map(&:id))
          end
        end

        context 'for a regular auction' do
          context 'when the auction is still running' do
            context 'when the auction has no bids' do
              let(:ar_auction) { create(:auction) }

              it 'veiled_bids should return an empty array' do
                expect(auction.veiled_bids(user)).to eq([])
              end
            end
            context 'when the auction has bids' do
              let(:ar_auction) { create(:auction, :multi_bid, :with_bidders, :running) }
              let(:ar_lowest_bid) { ar_bids_by_amount.first }
              let(:user) { auction.bids.first.bidder }

              it 'veiled_bids should return all bids' do
                expect(auction.veiled_bids(user)).to eq(auction.bids)
              end
            end
          end
        end
      end
    end
  end

  describe "#formatted_start_time" do
    it 'should equal the DcTimePresenter representation' do
      expect(auction.formatted_start_time).to eq(DcTimePresenter.convert_and_format(auction.start_datetime))
    end
  end

  describe "#formatted_end_time" do
    it 'should equal the DcTimePresenter representation' do
      expect(auction.formatted_end_time).to eq(DcTimePresenter.convert_and_format(auction.end_datetime))
    end
  end

  describe "#relative_start_time" do
    context 'when the start time is in the future' do
      let(:ar_auction) { create(:auction, start_datetime: 1.day.from_now) }

      it 'should be "in the_distance_of_time"' do
        expect(auction.relative_start_time).to eq("in #{distance_of_time_in_words(Time.now, ar_auction.start_datetime)}")
      end
    end

    context 'when the start time is in the past' do
      let(:ar_auction) { create(:auction, start_datetime: 1.day.ago) }

      it 'should be "in the_distance_of_time"' do
        expect(auction.relative_start_time).to eq("#{distance_of_time_in_words(Time.now, ar_auction.start_datetime)} ago")
      end
    end
  end

  describe '#relative_time_left' do
    let(:ar_auction) { create(:auction, start_datetime: 1.day.from_now) }

    it 'should be "the_distance_of_time left"' do
      expect(auction.relative_time_left).to eq("#{distance_of_time_in_words(Time.now, ar_auction.end_datetime)} left")
    end
  end

  describe "#html_summary" do
    let(:summary) { nil }
    let(:auction) { AuctionPresenter.new(build(:auction, summary: summary)) }

    it 'should return an empty string if the summary is blank' do
      expect(auction.html_summary).to be_blank
    end

    context 'bold text' do
      let(:summary) { 'This is **bold** text' }

      it 'should render correctly' do
        expect(auction.html_summary).to match("<strong>bold</strong>")
      end
    end

    context 'italicized text' do
      let(:summary) { 'This is _italic_ text' }

      it 'should render correctly' do
        expect(auction.html_summary).to match('<em>italic</em>')
      end
    end

    context 'autolinks' do
      let(:summary) { 'Please visit http://18f.gov anytime' }

      it 'should render correctly' do
        expect(auction.html_summary).to match('<a href="http://18f.gov">http://18f.gov</a>')
      end
    end

    context 'ignoring underscores in words' do
      let(:summary) { 'This_is_a_test' }

      it 'should not render as italicized' do
        expect(auction.html_summary).to_not match('<em>')
      end
    end

    context 'table rendering' do
      let(:summary) { "First Header|Second Header\n------------- | -------------\nContent Cell  | Content Cell\n" }

      it 'should render a table element' do
        expect(auction.html_summary).to match('<table>')
      end
    end
  end

  describe '#html_description' do
    let(:description) { nil }
    let(:auction) { AuctionPresenter.new(build(:auction, description: description)) }

    it 'should return an empty string if the description is blank' do
      expect(auction.html_description).to be_blank
    end

    context 'bold text' do
      let(:description) { 'This is **bold** text' }

      it 'should render correctly' do
        expect(auction.html_description).to match("<strong>bold</strong>")
      end
    end

    context 'italicized text' do
      let(:description) { 'This is _italic_ text' }

      it 'should render correctly' do
        expect(auction.html_description).to match('<em>italic</em>')
      end
    end

    context 'autolinks' do
      let(:description) { 'Please visit http://18f.gov anytime' }

      it 'should render correctly' do
        expect(auction.html_description).to match('<a href="http://18f.gov">http://18f.gov</a>')
      end
    end

    context 'ignoring underscores in words' do
      let(:description) { 'This_is_a_test' }

      it 'should not render as italicized' do
        expect(auction.html_description).to_not match('<em>')
      end
    end

    context 'table rendering' do
      let(:description) { "First Header|Second Header\n------------- | -------------\nContent Cell  | Content Cell\n" }

      it 'should render a table element' do
        expect(auction.html_description).to match('<table>')
      end
    end
  end
end
