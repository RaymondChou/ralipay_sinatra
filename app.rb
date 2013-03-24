require 'sinatra'
require 'ralipay'

get '/' do
  'A sinatra example using Ralipay Gem'
end

#注:有必要的话请混淆这些接口的访问地址,虽然已经进行rsa验签了,最好还是隐蔽为妙
#请不要验证ip,支付宝服务器可能变化
#请做好异常的捕获,防止被私自调用引起程序退出,gem内部会raise出来
#运用于产品环境之前请进行大量的测试!

#生成wap订单页面并跳转支付页面
get '/wap_pay_url' do
  #业务逻辑,获取订单属性等
  configs = {
      :partner => 'xxxxxxxxx',
      :seller_email => 'xxxxxxxx',
      :rsa_private_key_path => '/Users/ZhouYT/Desktop/rsa_private_key.pem',
      :rsa_public_key_path  => '/Users/ZhouYT/Desktop/alipay_public_key.pem',
      :subject => params[:subject].to_s,
      :out_trade_no => rand(9999).to_s,
      :total_fee => '0.01',
      :notify_url => 'http://xxxxxx',
      :merchant_url => 'http://xxxxx',
      :call_back_url => 'http://xxxxxx'
  }
  pay_url =  Ralipay::WapPayment.new(configs).generate_pay_url
  if pay_url.instance_of? String
    redirect pay_url
  end
end

#wap支付同步回调,建议不执行业务逻辑,只向用户渲染成功页面即可,业务执行放入异步通知
get '/wap_callback' do
  configs = {
      :rsa_private_key_path => '/Users/ZhouYT/Desktop/rsa_private_key.pem',
      :rsa_public_key_path  => '/Users/ZhouYT/Desktop/alipay_public_key.pem'
  }
  #如需要获取订单信息,请调用非问号方法
  if Ralipay::WapPayment.new(configs).callback_verify?(params)
    '支付成功'  #渲染view
    #业务逻辑
  else
    '支付失败'
    #业务逻辑,日志等
  end
end

#wap支付异步回调通知,由支付宝服务器发回,这个是可信的
post '/wap_notify' do
  configs = {
      :rsa_private_key_path => '/Users/ZhouYT/Desktop/rsa_private_key.pem',
      :rsa_public_key_path  => '/Users/ZhouYT/Desktop/alipay_public_key.pem'
  }
  #如需要获取订单信息,请调用非问号方法
  if Ralipay::WapPayment.new(configs).notify_verify?(params)
    #成功请向支付宝打印纯文本success
    'success'
    #业务逻辑
  else
    'error'
    #业务逻辑,日志等
  end
end

#客户端sdk支付同步回调,只做客户端的签名验证,可选不进行,验签通过就给客户端返回2，不通过就返回1
post '/client_callback' do
  configs = {
      :rsa_private_key_path => '/Users/ZhouYT/Desktop/rsa_private_key.pem',   #注意这里的密钥与wap的不同
      :rsa_public_key_path  => '/Users/ZhouYT/Desktop/alipay_public_key.pem'
  }
  if Ralipay::ClientPayment.new(configs).callback_verify?(params)
    '2'
  else
    '1'
  end
end

#客户端sdk支付异步回调通知,由支付宝服务器发回,这个是可信的
post '/client_notify' do
  configs = {
      :rsa_private_key_path => '/Users/ZhouYT/Desktop/rsa_private_key.pem',   #注意这里的密钥与wap的不同
      :rsa_public_key_path  => '/Users/ZhouYT/Desktop/alipay_public_key.pem'
  }
  #如需要获取订单信息,请调用非问号方法
  if Ralipay::ClientPayment.new(configs).notify_verify?(params)
    #成功请向支付宝打印纯文本success
    'success'
    #业务逻辑
  else
    'error'
    #业务逻辑,日志等
  end
end