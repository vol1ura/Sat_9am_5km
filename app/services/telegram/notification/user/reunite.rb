# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class Reunite < Base
        private

        def text
          athlete = @user.athlete

          <<~TEXT
            Здравствуйте, #{@user.first_name}.

            Похоже, в нашей базе было несколько профилей, принадлежащих вам \
            (например, вас когда-то могли внести вручную). \
            Бот объединил их в один в автоматическом режиме и ваши данные могли немного обновиться.

            Пожалуйста проверьте корректность данных и _обновите ваш QR-код_ с помощью команды /qrcode

            #{@user.full_name}
            *Пол:* #{athlete.gender}
            *Клуб:* #{athlete.club&.name || 'нет'}
            *Домашний забег:* #{athlete.event&.name || 'нет'}
            *Parkrun ID:* #{athlete.parkrun_code || 'нет'}
            *5 вёрст ID:* #{athlete.fiveverst_code || 'нет'}
            *RunPark ID:* #{athlete.runpark_code || 'нет'}

            В случае обнаружения неточностей, сообщите об этом волонтёрам вашего забега или напишите @vol1ura
          TEXT
        end
      end
    end
  end
end
