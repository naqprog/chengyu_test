class ExercisesMeanController < ApplicationController
  include ExerciseHelpers

  def new

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

  def create
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
      render :new, status: :unprocessable_entity and return
    else
      # 回答が見つかった
      @input_answer = Question.find(params[:input_answer_id])
    end

    # データベース処理
    new_response = Response.create(
      test_format: Constants.test_format.mean,
      test_kind: user_signed_in? ? current_user.setting.test_kind : Constants.test_kind.default,
      correct: @input_answer.id == @question.id ? true : false,
      user_id: user_signed_in? ? current_user.id : nil,
      question_id: @question.id
    )

    # 保存に成功したらshowにリダイレクト、失敗したらエラー処理
    if new_response.save
      redirect_to exercises_mean_show_path(question_id: @question.id, input_answer_id: params[:input_answer_id], use_letter_kind: params[:use_letter_kind])
    else
      raise '回答データの保存に失敗しました'
    end

  end

  def show
    # judgement_meanからデータ引き継ぎ
    @question = Question.find(params[:question_id])
    @input_answer = Question.find(params[:input_answer_id])
    @use_letter_kind = params[:use_letter_kind].to_i
  end

end
