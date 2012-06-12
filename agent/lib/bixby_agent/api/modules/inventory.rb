
module Bixby
class Inventory < BaseModule

    class << self

        def register_agent(uuid, public_key, hostname, port, password)
            req = JsonRequest.new("inventory:register_agent",
                    [ uuid, public_key, hostname, port, password ] )
            return req.exec()
        end

    end # self

end # Inventory
end # Bixby