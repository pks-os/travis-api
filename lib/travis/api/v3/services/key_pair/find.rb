module Travis::API::V3
  class Services::KeyPair::Find < Service
    def run!
      repository = check_login_and_find(:repository)
      paid_feature!(repository)
      result query.find(repository)
    end
  end
end
