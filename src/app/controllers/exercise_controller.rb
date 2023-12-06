class ExerciseController < ApplicationController

  def ask
    # 変数定義
    @choices = [] # 選択肢用配列

    # 現在の収録問題数を取得
    max_question = Question.count

    # ランダムで１問選ぶ
    now_question = rand(max_question) + 1
    @question = Question.find(now_question)

    # ログイン状況、言語設定を確認して「答え」を代入
    @true_answer = true_answer_check_lang(@question.chengyu_jianti, @question.chengyu_fanti)

    # 問題の答えを、重複を確認しながら配列に挿入する
    arr = @true_answer.dup
    while arr.length != 0 do
      str = arr.slice!(0)
      choices_no_duplication(@choices, str)
    end

    # 選択肢が10文字になるまで適当に問題から取ってきて、選択肢の残り6文字に埋める
    while @choices.length < 10 do
      # 今の出題ではない問題から１問ランダムで選ぶ
      sel_question = rand_exclude(max_question, now_question) + 1
      if(search_lang())
        str = Question.find(sel_question).chengyu_jianti
      else
        str = Question.find(sel_question).chengyu_fanti
      end
      choices_no_duplication(@choices, str.slice(rand(str.length)))
    end

    # 選択肢をシャッフルする
    @choices.shuffle!

  end

  def judgement
    # formからデータ引き継ぎ
    input_answer = params[:input_answer]
    question = Question.find(params[:question_id])

    # ログイン状況、言語設定を確認して「答え」を代入
    true_answer = true_answer_check_lang(question.chengyu_jianti, question.chengyu_fanti)

    ###
    # 本当はここでデータベース処理を行う
    ###

    # redirectするために変数引き継ぎ
    flash[:question_id] = question.id
    flash[:input_answer] = input_answer
    flash[:true_answer] = true_answer
    redirect_to action: :result
  end

  def result
    # judgementからデータ引き継ぎ
    @question = Question.find(flash[:question_id])
    @input_answer = flash[:input_answer]
    @true_answer = flash[:true_answer]
  end

  private

  # すでにその漢字があるかどうかを判定し、なかったら配列に追加する
  def choices_no_duplication(arr, str)
    if(arr.include?(str))
      return
    end
    arr << str
  end

  # 指定された数を除外したランダム
  def rand_exclude(max, exc)
    rr = exc
    while rr == exc do
      rr = rand(max) # ランダムがexcと別のものになるまで繰り返す
    end
    return rr
  end

  # 言語設定を利用して「正しい答え」を出力
  def true_answer_check_lang(chengyu_jianti, chengyu_fanti)
    if(search_lang())
      return chengyu_jianti
    else
      return chengyu_fanti
    end
  end

  # 言語設定の確認
  def search_lang()
    if user_signed_in?
      # ユーザ設定情報を返す
      return current_user.setting.letter_kind_jiantizi?
    else
      # デフォルトで簡体字を返す
      return true
    end
  end

end
