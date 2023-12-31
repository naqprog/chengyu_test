class ExercisesController < ApplicationController

  def ask_chengyu
    # 変数定義
    @choices = [] # 選択肢用配列

    # 現在の収録問題数を取得
    max_question = Question.count

    if user_signed_in?
      # すべての問題が「既知リスト」に入っていたら
      if max_question == current_user.known_num
        # エラーで返す
        flash[:danger] = "すべての問題が既知リストに入っています"
        return redirect_to root_path
      end
    end

    # 設定に従って今回の問題を選定
    now_question = choice_now_question(Constants.test_format.chengyu)

    unless(now_question) # エラーが返ってきてしまったら
      # 1問も過去に回答したことがなかったらエラーで返す
      flash[:danger] = "エラー(誤答データやお気に入りデータが見つからないなど)により出題ができません"
      return redirect_to root_path
    end

    @question = Question.find(now_question)

    # 今回用いる言語設定を言語設定や強制フラグから選択して
    # @use_letter_kindに代入する
    set_use_letter_kind

    # ログイン状況、言語設定を確認して「答え」を代入
    @true_answer = @question.chengyu_lang_setting(@use_letter_kind)

    # 問題の答えを、重複を確認しながら配列に挿入する
    arr = @true_answer.dup
    while arr.length != 0 do
      str = arr.slice!(0)
      choices_no_duplication(@choices, str)
    end

    # 選択肢が10文字になるまで適当に問題から取ってきて、選択肢の残り6文字に埋める
    # 選択肢の数はconfigで定数定義
    while @choices.length < Constants.ask.chengyu_question_select_num do
      # 今の出題ではない問題から１問ランダムで選ぶ
      sel_question = rand_exclude(max_question, now_question) + 1
      if( @use_letter_kind == Constants.letter_kind.jiantizi )
        str = Question.find(sel_question).chengyu_jianti
      else
        str = Question.find(sel_question).chengyu_fanti
      end
      choices_no_duplication(@choices, str.slice(rand(str.length)))
    end

    # 選択肢をシャッフルする
    @choices.shuffle!
    # 引き渡しのため連結データを作る
    @choices_join = @choices.join
  end

  def judgement_chengyu

    # formからデータ引き継ぎ
    input_answer = params[:input_answer]
    question = Question.find(params[:question_id])
    use_letter_kind = params[:use_letter_kind].to_i
    
    # ログイン状況、言語設定を確認して「答え」を代入
    true_answer = question.chengyu_lang_setting(use_letter_kind)

    # 回答文字数が足りなかったらエラーで戻す
    if(input_answer.length < 4)
      flash.now[:danger] = "回答の文字数が足りません"
      @question = question
      @choices = params[:choices_join].chars
      @input_answer = input_answer
      render :ask, status: :unprocessable_entity and return
    end

    # データベース処理
    Response.create(
      test_format: Constants.test_format.chengyu,
      test_kind: user_signed_in? ? current_user.setting.test_kind : Constants.test_kind.default,
      correct: input_answer == true_answer ? true : false,
      user_id: user_signed_in? ? current_user.id : nil,
      question_id: params[:question_id]
    )

    # redirectするために変数引き継ぎ
    flash[:question_id] = question.id
    flash[:input_answer] = input_answer
    flash[:true_answer] = true_answer
    redirect_to action: :result_chengyu
  end

  def result_chengyu
    # judgementからデータ引き継ぎ
    @question = Question.find(flash[:question_id])
    @input_answer = flash[:input_answer]
    @true_answer = flash[:true_answer]
  end

  def ask_mean
    # 変数定義
    @choices    = [] # 選択肢用配列

    # 現在の収録問題数を取得
    max_question = Question.count
    # 設定に従って今回の問題を選定
    now_question = choice_now_question(Constants.test_format.mean)
    unless(now_question) # エラーが返ってきてしまったら
      # 1問も過去に回答したことがなかったらエラーで返す
      flash[:danger] = "エラー(誤答データやお気に入りデータが見つからないなど)により出題ができません"
      return redirect_to root_path
    end
    @question = Question.find(now_question)

    # 今回用いる言語設定を言語設定や強制フラグから選択して
    # @use_letter_kindに代入する
    set_use_letter_kind

    # 「正答」となる問題(Question型)を選択肢(のテンポラリ変数)に入れる
    @choices << @question

    # その他、選択肢が4問になるまで適当に問題から取ってくる
    # 選択肢の数はconfigで定数定義
    while @choices.length < Constants.ask.mean_question_select_num do
      # 無限ループ注意
      loop do
        # 今の出題ではない問題から１問ランダムで選ぶ
        tmp_question = Question.find(rand_exclude(max_question, now_question) + 1)
        # 選ばれたidが既に選ばれている選択肢のidとかぶらない
        if(!@choices.include?(tmp_question))
          # ランダムで選んで来た問題が、出題される問題と「同義語」でないかチェック
          if(Synonym.same_check(@question.id, tmp_question.id))
            # チェックOKなので選択肢に追加する
            @choices << tmp_question
            break # loopをbreakして次の選択肢を選ぶ
          end
        end # falseなら問題選び直し
      end
    end

    # 選択肢をシャッフルする
    @choices.shuffle!

  end

  def judgement_mean
    # 変数定義
    @choices = []

    # formからデータ引き継ぎ
    @question = Question.find(params[:question_id])
    @use_letter_kind = params[:use_letter_kind]

    for num in 0..Constants.ask.mean_question_select_num - 1
      @choices << Question.find(params[:choices_id][num])
    end

    # 回答が選択されてなかったらエラーで戻す
    if(params[:input_answer_id] == nil)
      flash.now[:danger] = "回答が選択されていません"
      render :ask_mean, status: :unprocessable_entity and return
    else
      # 回答が見つかった
      @input_answer = Question.find(params[:input_answer_id])
    end

    # データベース処理
    Response.create(
      test_format: Constants.test_format.mean,
      test_kind: user_signed_in? ? current_user.setting.test_kind : Constants.test_kind.default,
      correct: @input_answer.id == @question.id ? true : false,
      user_id: user_signed_in? ? current_user.id : nil,
      question_id: @question.id
    )

    # redirectするために変数引き継ぎ
    flash[:question_id] = @question.id
    flash[:input_answer_id] = @input_answer.id
    flash[:use_letter_kind] = @use_letter_kind
    redirect_to action: :result_mean
  end

  def result_mean
    # judgement_meanからデータ引き継ぎ
    @question = Question.find(flash[:question_id])
    @input_answer = Question.find(flash[:input_answer_id])
    @use_letter_kind = flash[:use_letter_kind].to_i
  end

  private  

  # 今回用いる言語設定を言語設定や強制フラグから選択して
  # @use_letter_kindに代入する
  def set_use_letter_kind
    @use_letter_kind = 0 # 今回利用される言語設定

    if(params[:force_letter_kind])
      # リンクの情報から強制言語指定を確認
      @use_letter_kind = params[:force_letter_kind].to_i
    else
      if user_signed_in?
        # ユーザ設定情報から設定抽出
        @use_letter_kind = Setting.letter_kinds[current_user.setting.letter_kind]
      else
        # 例外を吐き出す
        raise RuntimeError, "サインインしてないのに出題に言語強制指定フラグが使われていない"
      end 
    end
  end

  # すでにその文字列があるかどうかを判定し、なかったら配列に追加する
  def choices_no_duplication(arr, str)
    if(arr.include?(str))
      return
    end
    arr << str
  end

  # 指定された数を除外したランダム
  def rand_exclude(max, exc)
    rr = exc
    # 無限ループ注意
    while rr == exc do
      rr = rand(max) # ランダムがexcと別のものになるまで繰り返す
    end
    return rr
  end

  # 設定等から問題を抽出した上で、ランダムで出題IDを決定する
  def choice_now_question(test_format)
    # ユーザの設定から出題種類を調べる
    if(user_signed_in?)
      kind = Setting.test_kinds[current_user.setting.test_kind]
    else
      kind = Constants.test_kind.default
    end

    # お気に入りから選ぶなら、データベースから選出した方が早いから、別に設ける
    if kind == Constants.test_kind.favorite
      # 専用メソッドからQuestion IDを得る
      return choice_favorite_question
    end

    qst = 0
    # 無限ループ注意
    loop do
      # ランダムで出題する１問を選ぶ
      case kind
      when Constants.test_kind.default then
        # すべての問題から選ぶ
        qst = rand(Question.count) + 1
      when Constants.test_kind.mistake then
        # 1問も過去に回答したことがなかったらエラーとしてnilで返す
        unless(Response.exists?(user_id: current_user.id, test_format: test_format, correct: false))
          return nil
        end
        qst = choice_mistake_question(test_format)
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
    my_mis = Response.where(user_id: current_user.id)
                      .where(test_format: test_format)
                      .where(correct: false)
    
    arr = []
    # 間違えた全部の回のIDを一時的に配列へ
    my_mis.each do |mis|
      arr << mis.question_id
    end
    # 配列のIDを重複がないようにする
    arr.uniq!
    return arr[rand(arr.length)]
  end

  # お気に入り問題のデータを参照してそこからランダムで出題してidを返す
  # このメソッドに関しては既知リストチェックも行う
  def choice_favorite_question
    # ブックマークデータから状況に即したデータ群を抜く
    my_fav = Bookmark.where(user_id: current_user.id)
                      .where(favorite: true)
                      .where(known: false)
    
    arr = []
    # 間違えた全部の回のIDを一時的に配列へ
    my_fav.each do |fav|
      arr << fav.question_id
    end
    # データの重複チェックは不要、ブックマークは重複しない(はず)
    return arr[rand(arr.length)]
  end

end
