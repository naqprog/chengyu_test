# Cheng-Yu Test

## サービス概要
Cheng-Yu Testは、中国語・成語の学習に特化した学習ゲーミフィケーションサービスです。

## 想定されるユーザー層
中国語学習中上級者(母語を日本語とする人)。年齢・性別は問いません。
成語の学習は初心者には不要ですので、あくまで既に学習しある程度のレベルに達している人をターゲットにします。

## サービスコンセプト
私は中国語を学習し、資格試験ではHSK(漢語水平考試)で5級合格している、いわゆる中〜上級者です。
現在のレベルになると、一般的な単語や文法以外に「成語」と呼ばれるものが、資格試験にも出題されるようになります。

この「成語(cheng yu)」とは、中国において古くから用いられる慣用句・ことわざ・格言であり、多くが４文字です(96%程度)。
５万個以上あると言われるその一部が日本に伝わって、現在四字熟語と言われています。
「半信半疑」「百発百中」などはその一例です。
そして現在も、中国人・台湾人らは小学生の頃からそれを暗記し、普段の生活、例えば日常会話、ニュースやドラマ、書籍など
様々なシーンで非常に多用していて、それは日本人が慣用句を使う頻度では全くありません。

つまるところ、中上級の中国語学習者はこの成語も当然学習しなければならないのですが、
この成語に特化した学習サイトは、当事者の私が調べた範囲では、日本には一切ありません。
(「単語」暗記アプリは多数あります。例えばHSK(漢語水平考試)公認単語トレーニングアプリ https://ch-edu.net/app/ )

その上で、私は中国語教育者ではなく一学習者なので、
成語について解説するというより、ゲーミフィケーション的に成語を覚える機会を作ることで、
多くの学習者の一助となるはずだと考え、本サイトを企画しました。

## 実装を予定している機能
### MVP
* 会員登録＆ログイン【Devise】
* テスト機能
  意味から成語を答える
  正答の４文字＋データベースから抽出したランダムの6文字の計10文字の漢字を表示して、４文字を当てさせる
  出題から回答するところまでjavascriptで組み上げる
* プロフィール
  * 過去の正答状況
    * 日付単位の正答率
    * 回答詳細状況
      (不正解問題を確認するため)
  * 簡体字・繁体字設定等のオプション
* 成語データ閲覧
  * 一覧表示
  * 詳細表示
    * 詳細検索用にオートコンプリート機能を採用【rails-autocomplete】
    * 正答率を計測
      *初回正答率、単純正答率などを算出表示
  * bookmark機能
* 管理画面【Active Admin】
  成語データは管理画面を通してDBに入力できるようにする
* デザイン落とし込み【Bootstrap】
  スマホで利用できることを重視
* 問題に関しては参考書「成語句句有意思(1年級)」を参考に、約140問をデータとして収録

### 本サービス
* ソーシャルログイン【Omniauth】
* 出題ルール詳細設定
  * 過去に間違った問題だけ
  * bookmarkした問題だけ
* 追加テスト機能
  成語から意味を答えさせる
* 簡易レコメンド出題機能
  * 正答率/難易度が近い問題を連続して出題

### 開発持続性(追加機能・追加サービス)
* 追加問題(高難易度)の作成
  * 問題難易度データの追加
* 管理画面での権限設定【CanCanCan】
  *成語データ作成のみができるユーザを作成し、作問を外注化できるようにする
* 成語文字数拡張
  ４文字だけではなく、例えば「百聞不如一見」(６文字)のような、10文字以下の成語に対応できるように改良
* 出題ルール詳細設定
  * 問題難易度指定
* 復習機能
  一定のタイミングで再ログインした際、昔出題された問題を出す
* 出題→正誤判定のajax化
* ユーザ登録時の導入テスト作成
  適した難易度の問題から始められるように(簡単すぎる問題は出さない)

### 画面遷移図
Figma：https://www.figma.com/file/MEm3OzukHPLZlQdGnGe9UQ/cheng-yu-test-%E9%81%B7%E7%A7%BB%E5%9B%B3?type=design&node-id=0%3A1&mode=design&t=kbcC2wSGhMaKHSKf-1

### 備考
* 画面遷移図上の注意点
  * ログインしているとき・していないときの表現がfigma上で難しいため列挙する
    * マイページ以下に入れない
    * 各所にbookmarkが現れない
    * 回答結果がサーバに記録されない。サーバ側もデータを保存しないため、正答率の計算に組み入れない。
  * その他
    * サインアップ時は出題オプションに関しては入力させず、初めて問題を解こうとする際に強制的に出題ルールページに飛ばす
    * 出題オプションに基づいて、出題形式を変更する
