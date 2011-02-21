module ActionMailer
  module JpMobile

    # 携帯メールアドレスの抽象クラス
    class MobileMailAddress
      MAIL_ADDR_REGEXP = nil
      def career_template_path
        self.class.to_s.split(/::/).last.downcase
      end

      def docomo?
        return (career_template_path == "docomo")
      end
      def au?
        return (career_template_path == "au")
      end
      def softbank?
        return (career_template_path == "softbank" || career_template_path == "iphone")
      end
      def willcom?
        return (career_template_path == "willcom")
      end
      def iphone?
        return (career_template_path == "iphone")
      end
    end

    class Au < MobileMailAddress
      MAIL_ADDR_REGEXP = /(ido\.ne\.jp|ezweb\.ne\.jp)$/
    end

    class Docomo < MobileMailAddress
      MAIL_ADDR_REGEXP = /docomo\.ne\.jp$/
    end

    class Softbank < MobileMailAddress
      MAIL_ADDR_REGEXP = /(softbank\.ne\.jp|\.vodafone\.ne\.jp|disney\.ne\.jp)$/
    end

    class Willcom < MobileMailAddress
      MAIL_ADDR_REGEXP = /pdx\.ne\.jp$/
    end

    class Iphone < MobileMailAddress
      MAIL_ADDR_REGEXP = /i\.softbank\.jp$/
    end

  end
end
