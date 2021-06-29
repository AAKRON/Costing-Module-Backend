require 'rails_helper'

RSpec.describe Screen, type: :model do
  it { is_expected.to validate_presence_of :screen_size  }
  it { is_expected.to validate_presence_of :cost  }
end
