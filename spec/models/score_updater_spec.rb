require 'spec_helper'

describe ScoreUpdater do

  describe '.update' do
    let!(:user_1) { create(:user)}
    let!(:user_2) { create(:user, email: 'tapajos@gmail.com')}
    let!(:bet_1) { create(:bet, user: user_1) }
    let!(:bet_2) { create(:bet, user: user_2) }
    let!(:team_a) { create(:team) }
    let!(:team_b) { create(:other_team) }
    let!(:match) { create(:match, number: 1, team_a: team_a, team_b: team_b) }
    let!(:match_2) { create(:match, number: 2, team_a: team_a, team_b: team_b) }
    let!(:match_bet_1) { create(:match_bet, bet: bet_1, match: match, goals_a: 2, goals_b: 0) }
    let!(:match_bet_2) { create(:match_bet, bet: bet_2, match: match, goals_a: 2, goals_b: 0) }
    let!(:match_2_bet_1) { create(:match_bet, bet: bet_1, match: match_2, goals_a: 2, goals_b: 0) }
    let!(:match_2_bet_2) { create(:match_bet, bet: bet_2, match: match_2, goals_a: 2, goals_b: 0) }

    it "set match 1 points" do
      expect(match_bet_1.points).to eql(0)
      match.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
      match_bet_1.reload
      expect(match_bet_1.points).to eql(match.total_points)
      expect(match_bet_1.scored_at).to be_between(5.seconds.ago, 5.seconds.from_now)
    end

    it "set match 2 points" do
      expect(match_bet_2.points).to eql(0)
      match.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
      match_bet_2.reload
      expect(match_bet_2.points).to eql(match.total_points)
      expect(match_bet_2.scored_at).to be_between(5.seconds.ago, 5.seconds.from_now)
    end

    it "set bet_1 points" do
      expect(match_bet_2.points).to eql(0)
      match.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
      match_2.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
      bet_1.reload
      expect(bet_1.points).to eql(match.total_points * 2)
    end

    it "set bet_2 points" do
      expect(match_bet_2.points).to eql(0)
      match.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
      bet_2.reload
      expect(bet_2.points).to eql(match.total_points)
    end

    it 'notifies users of the score' do
      UsersMailer.should_receive(:async_deliver).with(
        :match_bet_scored,
        match_bet_1.id,
        0,
        match.total_points
      )
      UsersMailer.should_receive(:async_deliver).with(
        :match_bet_scored,
        match_bet_2.id,
        0,
        match.total_points
      )
      match.update_attributes!(played_at: 1.day.ago, goals_a: 2, goals_b: 0)
    end
  end

end