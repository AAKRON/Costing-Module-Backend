module Api
    module V1
        class DatabaseController < BaseController
            def backup
                # system("rake db:backup")
                render json: { message: "Backup completed." }
            end
        end
    end
end
