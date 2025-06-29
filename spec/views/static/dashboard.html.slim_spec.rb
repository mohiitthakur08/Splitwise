require 'rails_helper'

RSpec.describe "static/dashboard.html.slim", type: :view do
  let(:user)    { create(:user, name: "You") }
  let(:friend)  { create(:user, name: "Friend") }

  before do
    assign(:users, [friend])
    assign(:total_balance, 0)
    assign(:you_owe, 50)
    assign(:you_are_owed, 30)
    assign(:friends_you_owe, { friend.id => 50 })
    assign(:friends_who_owe_you, { user.id => 30 })

    allow(view).to receive(:current_user).and_return(user)

    # Allow all other render calls to work as usual
    allow(view).to receive(:render).and_call_original

    # Stub only known problematic partials
    allow(view).to receive(:render).with('shared/expense_modal').and_return("")
    allow(view).to receive(:render).with('shared/settle_up_modal').and_return("")
    allow(view).to receive(:render).with('shared/friend_link', anything).and_return("FriendLink")
    allow(view).to receive(:render).with('shared/friend_balance_block', anything).and_return("FriendBalanceBlock")

    render template: "static/dashboard"
  end

  it "displays the dashboard title" do
    expect(rendered).to match /Dashboard/
  end

  it "shows the friend in the list" do
    expect(rendered).to include("FriendLink")
  end

  it "shows the total balance amounts" do
    expect(rendered).to match(/\$0\.00/)
    expect(rendered).to match(/\$50\.00/)
    expect(rendered).to match(/\$30\.00/)
  end
end
