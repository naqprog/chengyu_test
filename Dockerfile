FROM ruby:3.2.2
ENV RAILS_ENV=production

# yarnとnodejsのインストール
RUN set -x && curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn

# 変数の設定
ARG APP_ROOT="/app"
ARG CHROME_PACKAGES="libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2"
ARG CHROME_WEBDRIVER_PACKAGES="libnss3-dev"

# 必要なライブラリのインストール
RUN apt update -qq \
    && apt install -y ${CHROME_PACKAGES} \
    && apt install -y ${CHROME_WEBDRIVER_PACKAGES}

# Chrome & Chrome Driverのインストール
RUN CHROME_VERSION=`curl -sS https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE` \
    && curl -sS -o /tmp/chrome-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chrome-linux64.zip \
    && unzip -d /tmp /tmp/chrome-linux64.zip \
    && mkdir -p /usr/local/lib/chrome \
    && mv /tmp/chrome-linux64/* /usr/local/lib/chrome \
    && ln -s /usr/local/lib/chrome/chrome /usr/local/bin/chrome \
    && curl -sS -o /tmp/chromedriver-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip \
    && unzip -d /tmp /tmp/chromedriver-linux64.zip \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin

# Seleniumのスクショが文字化けしないように日本語フォントをインストール
RUN curl -sS -o /tmp/NotoSansCJKjp-hinted.zip https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
    && unzip -d /tmp/NotoSansCJKjp-hinted /tmp/NotoSansCJKjp-hinted.zip \
    && mkdir -p /usr/share/fonts/noto \
    && cp /tmp/NotoSansCJKjp-hinted/*.otf /usr/share/fonts/noto/ \
    && chmod 644 /usr/share/fonts/noto/*.otf \
    && fc-cache -fv

# ファイルを全コピー
WORKDIR /app
COPY ./src /app

# Gemのインストール
RUN gem update --system
RUN bundle config --local set path 'vendor/bundle' \
  && bundle install

# お掃除
RUN rm -rf /tmp/*

# プリコンパイルを走らせてから起動
COPY start.sh /start.sh
RUN chmod 744 /start.sh
CMD ["sh", "/start.sh"]
