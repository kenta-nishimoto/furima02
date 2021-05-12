class OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_item
  before_action :move_to_index

  def index
    @order = PayForm.new
  end

  def create
    @order = PayForm.new(order_params)
    if @order.valid? #バリデーションチェック
      pay_item # 追加
      @order.save #trueなら、フォームオブジェクトのsaveメソッドの呼び出し
      redirect_to root_path #処理後はリダイレクト
    else
      render 'index' # indexの再描写
    end
  end

  private

  def pay_item 
    Payjp.api_key = "sk_test_d11cda623508485e26a9f04f" #環境変数と合わせましょう
    # ↪︎Payjpクラスのapi_keyというインスタンスに秘密鍵を代入
    Payjp::Charge.create(
      # ↪︎決済に必要な情報は同様にGemが提供する、Payjp::Charge.createというクラスおよびクラスメソッドを使用
      amount: @item.price,  # 商品の値段
      card: order_params[:token],    # カードトークン
      currency: 'jpy'   
    )
  end

  def order_params
    params.require(:pay_form).permit(
      :postal_code,
      :prefecture_id,
      :city,
      :address,
      :building,
      :phone_number
    ).merge(user_id: current_user.id,item_id: params[:item_id] , token: params[:token])
  end
  
  def set_item
    @item = Item.find(params[:item_id])
  end

  def move_to_index
    return redirect_to root_path if current_user.id == @item.user.id || @item.order.present? # 追加
  end

end
