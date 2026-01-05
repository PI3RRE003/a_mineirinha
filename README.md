# 🧀 A Mineirinha - Gestão de Vendas e Fidelidade

Um sistema de gestão de pedidos e controle de faturamento desenvolvido em Ruby on Rails, focado em pequenos negócios de alimentação (como vendas de pão de queijo). O sistema conta com controle de estoque, histórico de vendas, relatórios em PDF e sistema de pontos de fidelidade.

https://a-mineirinha.onrender.com/
---

## 🚀 Funcionalidades

- **Painel da Cozinha:** Monitoramento de pedidos em tempo real (Recebidos -> Preparando -> Concluídos).
- **Histórico de Vendas:** Relatório detalhado com filtros por data e cálculo de faturamento.
- **Produto Campeão:** Identificação automática do item mais vendido no período selecionado.
- **Relatórios em PDF:** Geração de relatórios profissionais para impressão usando WickedPDF.
- **Sistema de Fidelidade:** Atribuição automática de pontos aos clientes em produtos específicos (ex: pacotes de 1kg).
- **Gestão de Produtos:** Cadastro, edição e arquivamento de itens (Soft Delete).

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** Ruby 3.x
- **Framework:** Ruby on Rails 7/8
- **Banco de Dados:** SQLite (Desenvolvimento) / PostgreSQL (Produção no Render)
- **Estilização:** Tailwind CSS (via CDN e Tailwind-rails)
- **PDF:** WickedPDF & wkhtmltopdf
- **Autenticação:** Devise (Controle de Admin e Clientes)

---

## 💻 Como rodar localmente

### No Windows (Configuração realizada)
1. **Instalar Ruby:** Recomendado via [RubyInstaller](https://rubyinstaller.org/).
2. **Dependência PDF:** - Baixe e instale o [wkhtmltopdf](https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.msvc2015-win64.exe).
   - O caminho padrão deve ser `C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe`.
3. **Setup do projeto:**
   ```bash
   bundle install
   rails db:prepare
   rails s


### No macOS / Linux

1. **Instalar Ruby**: Via rbenv ou rvm.

2. **Dependência PDF**:

Bash

brew install homebrew/cask/wkhtmltopdf
3. Setup do projeto:

Bash

3. **Setup do projeto:**
   ```bash
   bundle install
   rails db:prepare
   rails s

📄 Licença
Este projeto é para fins educacionais e de gestão interna.

## Telas

<img width="1900" height="876" alt="Captura de tela 2025-12-27 194803" src="https://github.com/user-attachments/assets/28590e96-08f7-4012-8932-a6b52139bc5e" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194837" src="https://github.com/user-attachments/assets/72d0c0ae-64a2-4703-b1d0-fa50b49fffa8" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194850" src="https://github.com/user-attachments/assets/03ea36ff-b088-4c43-93cc-81bd894a07b5" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194909" src="https://github.com/user-attachments/assets/bd509959-324c-4db8-afc4-54eb33ac4a36" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194923" src="https://github.com/user-attachments/assets/e872f39a-1bff-4c45-92e0-4485e2a684ed" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194932" src="https://github.com/user-attachments/assets/9a0dc5ec-cc76-47fc-9000-168ad893d1a5" />
<img width="1920" height="1080" alt="Captura de tela 2025-12-27 194942" src="https://github.com/user-attachments/assets/655a9a9a-4ca3-4d9e-af48-bd519131befe" />





