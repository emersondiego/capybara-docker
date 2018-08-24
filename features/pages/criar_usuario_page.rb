class User < SitePrism::Page
  set_url '/users/new'

  element :nome, '#user_name'
  element :sobrenome, '#user_lastname'
  element :email, '#user_email'
  element :endereco, '#user_address'
  element :universidade, '#user_university'
  element :profissao, '#user_profile'
  element :genero, '#user_gender'
  element :idade, '#user_age'
  element :btn_criar, 'input[value="Criar"]'
  
  def preencher_usuario
    nome.set 'Teste'
    sobrenome.set 'Testes'
    email.set 'teste@tte.com'
    endereco.set 'Rua um dois'
    universidade.set 'Unib'
    profissao.set 'Analista'
    genero.set 'Masculino'
    idade.set '30'
    btn_criar.click
  end
end

