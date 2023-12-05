class TestQuestionController < ApplicationController

  def index
    # 変数定義
    @choices = [] # 選択肢用配列
    # 言語仮設定

    # 現在の収録問題数を取得
    max_question = Question.count

    # ランダムで１問選ぶ
    now_question = rand(max_question) + 1
    @question = Question.find(now_question)

    # ログイン状況、言語設定を確認して「答え」を代入
    if(search_lang())
      @true_answer = @question.chengyu_jianti
    else
      @true_answer = @question.chengyu_fanti
    end

    # 問題の答えを、重複を確認しながら配列に挿入する
    arr = @true_answer.dup
    while arr.length != 0 do
      str = arr.slice!(0)
      choices_no_duplication(@choices, str)
    end

    # 選択肢が10文字になるまで適当に問題から取ってきて、選択肢の残り6文字に埋める
    while @choices.length < 10 do
      sel_question = rand_exclude(max_question, now_question) + 1 # 今の出題ではない問題から１問ランダムで選ぶ
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

  # すでにその漢字があるかどうかを判定し、なかったら配列に追加する
  def choices_no_duplication(ar, st)
    if(ar.include?(st))
      return
    end
    ar << st
  end

  # 指定された数を除外したランダム
  def rand_exclude(max, exc)
    rr = exc
    while rr == exc do
      rr = rand(max) # ランダムがexcと別のものになるまで繰り返す
    end
    return rr
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
