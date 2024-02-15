class ExercisesChengyuController < ApplicationController
  include ExerciseHelpers

  def new
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

  def create

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
      render :new, status: :unprocessable_entity and return
    end

    # データベース処理
    new_response = Response.new(
      test_format: Constants.test_format.chengyu,
      test_kind: user_signed_in? ? current_user.setting.test_kind : Constants.test_kind.default,
      correct: input_answer == true_answer ? true : false,
      user_id: user_signed_in? ? current_user.id : nil,
      question_id: params[:question_id]
    )

    # 保存に成功したらshowにリダイレクト、失敗したらエラー処理
    if new_response.save
      redirect_to exercises_chengyu_show_path(question_id: params[:question_id], input_answer: params[:input_answer], true_answer: true_answer)
    else
      raise '回答データの保存に失敗しました'
    end

  end

  def show
    # judgementからデータ引き継ぎ
    @question = Question.find(params[:question_id])
    @input_answer = params[:input_answer]
    @true_answer = params[:true_answer]
  end

  private

  # すでにその文字列があるかどうかを判定し、なかったら配列に追加する
  def choices_no_duplication(arr, str)
    if(arr.include?(str))
      return
    end
    arr << str
  end

end
