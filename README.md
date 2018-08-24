# Automatizando end-to-end com Docker

1- Criar pasta e criar estrutura do projeto

```
Instalar:
  gem install cucumber
  gem install rspec
Executar:
  cucumber --init
```

2 - Na pasta raiz criar o arquivo Gemfile

```ruby
source 'http://rubygems.org'

gem 'capybara'
gem 'chromedriver-helper'
gem 'cucumber'
gem 'geckodriver-helper', '~> 0.21.0'
gem 'rspec'
gem 'selenium-webdriver'
gem 'site_prism', '2.13'
```

3 - Adicionar os requires no arquivo env.rb e configurar o Capybara

```ruby
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = 'https://automacaocombatista.herokuapp.com'
  config.default_max_wait_time = 10
end
```

4 - Criar duas pastas dentro de features specs (executar as features) e pages (po)

5 - Na pasta raiz criar a pasta reports

6 - Criar arquivo hooks.rb dentro de support para configurar o screenshot ao final de cada cenário

```ruby
After do |scenario|
  scenario_name = scenario.name.gsub(/\s+/,'_').tr('/','_')
  if scenario.failed?
    tirar_foto(scenario_name.downcase!, 'falhou')
  else
    tirar_foto(scenario_name.downcase!, 'passou')
  end
end
```

7 - Criar arquivo helper.rb dentro de support

````ruby
module Helper
  def tirar_foto(nome_arquivo, resultado)
    caminho_arquivo = "reports/screenshot/test_#{resultado}"
    foto = "#{caminho_arquivo}/#{nome_arquivo}.png"
    page.save_screenshot(foto)
    embed(foto, 'image/png', 'Clique Aqui!')
  end
end
````

8 - No env.rb adicionar require dos helper criado e inclui-lo como global

````ruby
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require_relative 'helper.rb'

World(Helper)

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = 'https://automacaocombatista.herokuapp.com'
  config.default_max_wait_time = 10
end
````

10 - Configurar o cucumber, criar arquivo cucumber.yml na pasta raiz

````yml
---

default: -p pretty -p homolog

pretty: --format pretty
homolog: AMBIENTE=homolog
````

11 - Dentro de support criar pasta ambientes e criar arquivo homolog.yml passando a url do ambiente

````yml
url_padrao: 'https://automacaocombatista.herokuapp.com'
````

12 - Configurar o ambiente dentro do arquivo env.rb para que ele possa buscar a url dentro da pasta ambientes

````ruby
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require_relative 'helper.rb'

AMBIENTE = ENV['AMBIENTE']
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/ambientes/#{AMBIENTE}.yml")

World(Helper)

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = 'https://automacaocombatista.herokuapp.com'
  config.default_max_wait_time = 10
end
````

13 - Ainda no env.rb alterar a url padrão do capybara para chamar pela constante CONFIG criada

````ruby
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require_relative 'helper.rb'

AMBIENTE = ENV['AMBIENTE']
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/ambientes/#{AMBIENTE}.yml")

World(Helper)

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = CONFIG['url_padrao']
  config.default_max_wait_time = 10
end
````

14 - Criar cenario criar_usuario.feature dentro de specs

````ruby
#language: pt

Funcionalidade: Criar Usuario

-Eu como Usuario
-Quero me cadastrar com sucesso

@criar_usuario
Cenario: Cadastrar com sucesso
Quando eu cadastro meu usuario
Entao verifico se o usuario foi cadastrado
````

15 - Criar arquivo criar_usuario.rb em step-definitions com os steps gerados no terminal

````ruby
Quando("eu cadastro meu usuario") do
  pending # Write code here that turns the phrase above into concrete actions
end

Entao("verifico se o usuario foi cadastrado") do
  pending # Write code here that turns the phrase above into concrete actions
end
````

16 - Criar nosso Pageobject para mapear os elementos em pages/criar_usuario_page.rb

````ruby
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
````

17 - Criar um arquivo em support chamado page_helper.rb

````ruby
Dir[File.join(File.dirname(__FILE__), "../pages/*_page.rb")].each { |file| require file }

module Pages
  def user
    @user ||= User.new
  end
end
````

18 - Incluir o modulo Pages criado como global dentro de env.rb e dar um require do arquivo

````ruby
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'site_prism'
require_relative 'helper.rb'
require_relative 'page_helper.rb'

AMBIENTE = ENV['AMBIENTE']
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/ambientes/#{AMBIENTE}.yml")

World(Helper)
World(Pages)

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = CONFIG['url_padrao']
  config.default_max_wait_time = 10
end
````

18 - Acrescentar em nosso cucumber.yml relatório

````yml
---

default: -p pretty -p homolog -p html

pretty: --format pretty
homolog: AMBIENTE=homolog
html: --format html --out=reports/relatorio.html
````

19 - Arquivo criar_usuario.rb preenchido com os dados do PO

````ruby
Quando("eu cadastro meu usuario") do
  user.load
  user.preencher_usuario
end

Entao("verifico se o usuario foi cadastrado") do
  texto = find('#notice')
  expect(texto.text).to eq 'Usuário Criado com sucesso'
end
````

20 - Rodando o cenario

comando
``
bundle exec cucumber -t@criar_usuario
``

Saida terminal:

````ruby
╰─➤  bundle exec cucumber -t@criar_usuario
Using the default, pretty, homolog and html profiles...
# language: pt
Funcionalidade: Criar Usuario
-Eu como Usuario
-Quero me cadastrar com sucesso

  @criar_usuario
  Cenario: Cadastrar com sucesso               # features/specs/criar_usuario.feature:9
    Quando eu cadastro meu usuario             # features/step_definitions/criar_usuario.rb:1
    Entao verifico se o usuario foi cadastrado # features/step_definitions/criar_usuario.rb:6

1 scenario (1 passed)
2 steps (2 passed)
0m12.122s
````

## Rodar em modo headless do chrome

1 - No arquivo cumcumber.yml incluir navegadores e chamar constante no default

````yml
---

default: -p pretty -p homolog -p html -p chrome_headless

pretty: --format pretty
homolog: AMBIENTE=homolog
html: --format html --out=reports/relatorio.html
chrome: BROWSER=chrome
chrome_headless: BROWSER=chrome_headless
````

2 -  No arquivo env.rb alterar a chamada do config.default_driver:
Dessa forma conseguiremos sobrescrever o selenium para o que desejamos chamar no momento

De 
````ruby
  config.default_driver = :selenium_chrome
````
Para 
````ruby
    config.default_driver = :selenium
````

3 - Também no arquivo env.rb configurar a chamada tanto abrindo navegador e em modo headless

Primeiro criar a constante, onde desta forma o browser será informado no arquivo cucumber;yml

````ruby
BROWSER = ENV['BROWSER']
````

Em seguida incluir os drivers:

````ruby
Capybara.register_driver :selenium do |app|
  if BROWSER.eql?('chrome')
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  elsif BROWSER.eql?('chrome_headless')
    Capybara::Selenium::Driver.new(app, :browser => :chrome,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
        'chromeOptions'=> { 'args' => ['--headless', 'disable-gpu'] }
      )  
    )
  end
end
````

4 - Incluir as constantes criadas no env.rb no arquivo cucumber.yml

````yml
---

default: -p pretty -p homolog -p html -p chrome_headless

pretty: --format pretty
homolog: AMBIENTE=homolog
html: --format html --out=reports/relatorio.html
chrome: BROWSER=chrome
chrome_headless: BROWSER=chrome_headless
````

Caso queira mudar um para o abrindo navegador mude para:

````yml
default: -p pretty -p homolog -p html -p chrome
````

## Rodando Docker

1 - Build a imagem cirada pelo arquivo Dockerfile

````ruby
╰─➤  docker build -t < nome de sua imagem > .
````

Execute o test diretamente pelo Docker

````ruby
╰─➤  docker run --rm < nome de sua imagem > bundle exec cucumber features/specs/criar_usuario.feature
````

```
Atenção como não temos interface gráfica dentro do Docker rodar sempre em modo Headless seus testes.
```

Pronto! Agora você possui um teste end-to-end automatizado completo.

OBRIGADO ;)