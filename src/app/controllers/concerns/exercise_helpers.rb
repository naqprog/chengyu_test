module ExerciseHelpers
  extend ActiveSupport::Concern

  private

  # 設定等から問題を抽出した上で、ランダムで出題IDを決定する
  def choice_now_question(test_format)
    # ユーザの設定から出題種類を調べる
    if(user_signed_in?)
      kind = Setting.test_kinds[current_user.setting.test_kind]
    else
      kind = Constants.test_kind.default
    end

    # お気に入りから選ぶなら、データベースから選出した方が早いから、
    # 専用メソッドからQuestion IDを得る
    return choice_favorite_question if kind == Constants.test_kind.favorite

    qst = 0
    # 無限ループ注意
    loop do
      # ランダムで出題する１問を選ぶ
      case kind
      when Constants.test_kind.default then
        # すべての問題から選ぶ
        qst = rand(Question.count) + 1
      when Constants.test_kind.mistake then
        # 1問も過去に誤答したことがなかったらエラーとしてnilで返す
        unless(Response.exists?(user_id: current_user.id, test_format: test_format, correct: false))
          return nil
        end
        qst = choice_mistake_question(test_format)
      when Constants.test_kind.rate_low then
        # 1問も過去に誤答したことがなかったらエラーとしてnilで返す
        unless(Response.exists?(user_id: current_user.id, test_format: test_format, correct: false))
          return nil
        end
        qst = choice_rate_low_question(test_format, 0.4) # 一旦正答率４割以下で設定
        unless(qst) # エラー(正答率以下の問題が見つからない)でnilが返ってきてしまったら
          return nil
        end
      else
        # 例外を吐き出す
        raise RuntimeError, "ユーザ設定の出題形式設定に代入されている数値がおかしい"
      end
      # ログインしているなら、「既知リストに入ってない」ことを調べる
      if user_signed_in?
        if !current_user.known?(Question.find(qst))
          return qst # メソッドから脱出
        end
      else
        return qst # メソッドから脱出
      end
    end
  end

  # 過去に間違えた問題のデータを参照してそこからランダムで出題してidを返す
  def choice_mistake_question(test_format)
    # 自分の、テストの種類(成語を聞くか、意味を聞くか)が一致していて、間違った記録を抽出
    my_mis = Response.where(user_id: current_user.id, test_format: test_format, correct: false)
                     .pluck(:question_id)
    # 配列のIDを重複がないようにする
    arr.uniq!
    return arr.sample
  end

  # 正答率が低い問題のデータを参照してそこからランダムで出題してidを返す
  def choice_rate_low_question(test_format, input_rate)
    # 自分の、テストの種類(成語を聞くか、意味を聞くか)が一致している記録を抽出
    my_data = Response.where(user_id: current_user.id)
                      .where(test_format: test_format)

    arr_mis = []
    arr_mis_uniq = []
    arr_cor = []
    arr_fix = []
    # 記録で正解したか不正解だったかを調べて、それぞれの配列に格納する
    my_data.each do |data|
      if data.correct
        arr_cor << data.question_id # 正解したらこちらに
      else
        arr_mis << data.question_id # 不正解ならこちらに
      end
    end
    # 調査用にuniq配列を作る
    arr_mis_uniq = arr_mis.uniq
    arr_mis_uniq.each do |mis_uniq|
      # mis_uniqの１つ１つは間違ったことのあるID
      # これが「正答率がinput_rateより下回っていることを調べて、条件にかなう配列を作れば良い」
      am = arr_mis.count(mis_uniq) # 今までに 問題ID mis_uniq に対し、間違った個数
      ac = arr_cor.count(mis_uniq) # 今までに 問題ID mis_uniq に対し、正答した個数
      cor_rate = ac / (am + ac).to_f # 正答率
      if( cor_rate < input_rate )
        # せっかくなので既知リストに入っていないことも保証する
        if user_signed_in?
          if !current_user.known?(Question.find(mis_uniq))
            arr_fix << mis_uniq # この問題ID mis_uniqは正答率が低いことを証明できた！
          end
        end
      end
    end
    # 完成した配列が空っぽのまま、つまり全ての問題で正答率が高いならエラーとしてnilを返す
    if(arr_fix.empty?)
      return nil
    end
    # 完成した配列は「全て正答率が低い問題ID群」だから、ここからランダムで出題すればいい
    return arr_fix.sample
  end

  # お気に入り問題のデータを参照してそこからランダムで出題してidを返す
  # このメソッドに関しては既知リストチェックも行う
  def choice_favorite_question
    # ブックマークデータから状況に即したデータ群を選択し、その中からquestion_idの配列を抽出する
    my_fav = Bookmark.where(user_id: current_user.id, favorite: true, known: false)
                     .pluck(:question_id)
    # 配列群からランダムで１つ選択する
    return my_fav.sample
  end

  # 指定された数を除外したランダム
  def rand_exclude(max, exc)
    # 0からmax-1までの配列を作成し、続いてその配列からexcを排除し、その中からランダムで１つ選んで返す
    (0...max).reject { |n| n == exc }.sample
  end

  # 今回用いる言語設定を言語設定や強制フラグから選択して
  # 言語設定 @use_letter_kindに代入する
  def set_use_letter_kind
    if(params[:force_letter_kind])
      # リンクの情報から強制言語指定を確認
      @use_letter_kind = params[:force_letter_kind].to_i
    elsif user_signed_in?
      # ユーザ設定情報から設定抽出
      @use_letter_kind = Setting.letter_kinds[current_user.setting.letter_kind]
    else
      # 例外を吐き出す
      raise RuntimeError, "サインインしてないのに出題に言語強制指定フラグが使われていない"
    end
  end

end
