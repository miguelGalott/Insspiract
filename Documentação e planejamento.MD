Insspiract: Planejamento do Projeto Integrador

Curso Técnico em Desenvolvimento de Sistemas | Senac-ES, Unidade Serra Equipe: Miguel (Backend) · Dante (Frontend) · Isacar (Banco de Dados) - Dhyonatan (Documentação)



1\. Definição do Projeto

1.1 Resumo

O Insspiract é um aplicativo mobile para gerenciar a reserva da Sala Inspira, ambiente com dispositivos tecnológicos avançados voltado a melhorar o aprendizado. O app centraliza reservas, cancelamentos, trocas de horário e comunicação entre professores e secretaria.



1.2 Problema

Hoje a reserva é feita de modo manual e informal: o professor avisa a secretaria (presencialmente ou verbalmente) e a confirmação leva de dias a semanas. Cancelamentos e mudanças ocorrem sem aviso, desorganizando a agenda.



Quem sofre	         Impacto

Professores	     Perdem tempo esperando e têm aulas reorganizadas de última hora

Alunos	             Sem previsibilidade sobre quando terão acesso à sala

Secretaria	     Controle manual de agenda, conflitos e retrabalho





Como é resolvido hoje: comunicação informal com a secretaria, sem sistema centralizado.



1.3 Justificativa

Reduz o tempo de resposta de dias/semanas para minutos.

Evita conflitos de agenda (dois professores no mesmo horário).

Reduz a sobrecarga da secretaria.

Dá transparência: a disponibilidade é vista em tempo real.

Gera dados (reservas, cancelamentos, reclamações) para decisões sobre manutenção e uso do espaço.

1.4 Público-alvo e escopo de perfis

Ajuste importante: o documento original citava alunos em vários trechos, mas os objetivos e requisitos só contemplam professor e secretaria. Para ficar coerente, a versão 1.0 trata assim:



Professores (usuários principais): reservam, cancelam e negociam horários.

Secretaria (administradora): valida usuários, gerencia reservas, envia avisos e emite relatórios.

1.5 Objetivo geral

Desenvolver um aplicativo mobile para gerenciamento e reserva da Sala Inspira do Senac-ES Unidade Serra, permitindo que professores e secretaria solicitem, acompanhem e administrem o uso do espaço de forma organizada e centralizada.



1.6 Objetivos específicos

Cadastrar usuários (professor e secretaria) com validação da secretaria.

Implementar login segmentado por perfil.

Permitir que a secretaria envie avisos e solicitações aos professores.

Permitir que professores reservem, cancelem e transfiram horários entre si.

Implementar fila de espera que redistribui horários cancelados automaticamente.

Gerar relatórios de uso da sala para a secretaria.

1.7 Benefícios esperados (e como medir)

Benefício Indicador sugerido

Menos espera pela confirmação	 

Tempo médio entre solicitação e confirmação (meta: minutos)

Menos conflitos de agenda	Número de choques de horário (meta: zero)

Melhor aproveitamento da sala	Taxa de ocupação e horários reaproveitados pela fila

Menos trabalho manual	Redução de solicitações presenciais à secretaria

2\. Levantamento de Requisitos

2.1 Requisitos funcionais

Cód.	Descrição	Prioridade

RF01	Cadastro de usuários (professor/secretaria), mediante validação da secretaria	Essencial

RF02	Login segmentado por perfil	Essencial

RF03	Secretaria envia avisos e solicitações aos professores	Essencial

RF04	Secretaria adiciona e gerencia usuários (unificado com o antigo RF01/RF04 duplicado)	Essencial

RF05	Professor reserva um horário disponível na sala (estava implícito, faltava como requisito)	Essencial

RF06	Secretaria cancela (desmarca) agendamentos	Essencial

RF07	Secretaria visualiza e responde solicitações dos professores	Essencial

RF08	Professor registra reclamações sobre a sala	Importante

RF09	Professor cancela seus próprios agendamentos	Essencial

RF10	Troca/negociação de horário entre professores por mensagem interna	Importante

RF11	Realocação automática em fila quando um horário é cancelado	Importante

RF12	Relatório de uso (reservas, cancelamentos, reclamações)	Importante

RF13	Professor solicita item/recurso à secretaria (aparecia nos casos de uso sem requisito)	Desejável

RF14	Notificações (push ou e-mail) para confirmação, cancelamento e vaga na fila	Importante

RF15	Confirmação da reserva pela secretaria (ver observação abaixo)	Essencial





2.2 Requisitos não funcionais

Cód.	Descrição

RNF01	Interface responsiva, compatível com celulares de baixa/média capacidade

RNF02	Tempo de resposta < 3 s nas operações principais (login, consulta e reserva)

RNF03	Autenticação por e-mail, senha e código de verificação

RNF04	Segurança dos dados: senhas com hash (ex.: bcrypt), comunicação via HTTPS, tokens de sessão (JWT), conformidade com a LGPD

RNF05	Disponibilidade 24 h (dependente do servidor do Senac)

RNF06	Identidade visual moderna (translucidez, bordas arredondadas, imagem institucional do Senac)

RNF07	Mensagens de erro claras em todos os formulários

RNF08	Backups periódicos do banco de dados



2.3 Regras de negócio

RN01: a mesma sala não pode ter duas reservas ativas no mesmo dia e horário (garantido por restrição UNIQUE no banco, além da validação no back-end).



RN02: só usuários validados pela secretaria acessam o sistema.



RN03: ao cancelar, o horário vai para o primeiro da fila; se ele não aceitar em prazo definido (ex.: 24 h), passa ao seguinte.



RN04: professores só cancelam reservas próprias; a secretaria cancela qualquer uma, com aviso ao professor.

2.4 Restrições

Depende da adesão da secretaria (valida usuários e libera reservas).

Banco de dados MySQL.

Hospedagem em servidor cedido pelo Senac.

Distribuição via Play Store, sujeita à aprovação do Senac.

Não há similares conhecidos voltados ao Senac; expansões dependem de solicitação institucional.

Tecnologia do app: definir uma só. O original citava "Kotlin e Dart". Recomendação: Flutter (Dart), por ter um único código-base, boa curva de aprendizado e ótima integração com APIs. Kotlin nativo só se a equipe já tiver domínio.

3\. Pesquisa

Sistemas a analisar: apps de reserva de salas de reunião/laboratórios/auditórios (ex.: Google Calendar com recursos, Microsoft Bookings, Skedda) e módulos de reserva de espaços em sistemas acadêmicos.



Perguntas norteadoras:



Como tratam conflitos de agendamento?

Como funciona a fila de espera após um cancelamento?

Que mecanismos de notificação usam?

O que pode ser simplificado para a realidade do Senac?

Tecnologias: Flutter × Kotlin; API intermediária com MySQL (o app nunca acessa o banco diretamente); autenticação segura e verificação por e-mail; notificações (Firebase Cloud Messaging); lógica de filas.



Entrega sugerida: uma tabela comparativa de 2 a 3 sistemas pesquisados, para mostrar na apresentação que houve pesquisa de fato.



4\. Planejamento Técnico

Camada	Escolha

App mobile	Flutter (Dart)

API back-end	A decidir pela equipe: Node.js (Express), Spring Boot ou ASP.NET Core

Banco de dados	MySQL

Autenticação	JWT + hash de senha + código de verificação por e-mail

E-mail	Serviço SMTP (ex.: Nodemailer/SendGrid)

Notificações	Firebase Cloud Messaging

Ferramentas	VS Code, Android Studio, MySQL Workbench, Git/GitHub, Figma, Draw.io, Trello

Arquitetura: App Flutter → API REST (HTTPS) → MySQL. O app mobile nunca se conecta direto ao banco, por segurança.



5\. Modelagem

5.1 Protótipos

O original dispensava protótipos. Recomendação: fazer ao menos wireframes simples no Figma das telas principais (login, agenda, reserva, painel da secretaria). Isso reduz retrabalho no front-end e rende bom material para a apresentação.



5.2 Casos de uso

Secretaria: fazer login · validar e cadastrar usuário · enviar aviso/solicitação · desmarcar agendamento · responder solicitações · consultar relatório de uso. Professor: fazer cadastro e login · consultar disponibilidade · reservar horário · cancelar reserva própria · registrar reclamação · solicitar item à secretaria · negociar/ceder horário · receber notificações.



5.3 Entidades (diagrama de classes)

Usuário (base): id, nome, e-mail, senha (hash), tipo, status (pendente/ativo/bloqueado)

Professor (herda): diploma, área de ensino

Secretaria (herda): matrícula funcional

Sala: id, nome, descrição, recursos

Reserva: id, data, hora\_inicio, hora\_fim, id\_professor, id\_sala, status (pendente/confirmada/cancelada/em fila)

FilaEspera: id, id\_sala, data, horário, id\_professor, posição, status

Solicitação: id, id\_usuário, tipo (reclamação/pedido), descrição, status, resposta

Aviso: id, id\_secretaria, mensagem, data\_envio

Mensagem (nova): id, remetente, destinatário, texto, data, usada na negociação de horários (RF10)

Notificação (nova): id, id\_usuário, texto, lida

Observação: "sala habitual" foi removida de Professor, pois não tinha uso nos requisitos. A entidade de fila foi ajustada para guardar a vaga disputada (sala + data + horário), pois a ligação com "reserva cancelada" sozinha não bastava.



5.4 Banco de dados

Tabelas: usuarios, professores, secretaria, salas, reservas, fila\_espera, solicitacoes, avisos, mensagens, notificacoes.



Relacionamentos:



Usuário 1:N Reservas · Sala 1:N Reservas

Reserva cancelada → aciona a fila daquele horário

Solicitação N:1 Usuário, com resposta da secretaria

professores e secretaria ligam-se a usuarios por chave estrangeira (1:1)

Integridade: UNIQUE (id\_sala, data, hora\_inicio) para reservas ativas.



5.5 Fluxograma

Início → Login

&#x20;  ├─ Sem cadastro? → Solicitar cadastro → Validação da secretaria → (aprovado) → Login

&#x20;  └─ Autenticação (e-mail + senha + código)

&#x20;       ↓

&#x20;  Menu por perfil

&#x20;    Professor: ver agenda · reservar · cancelar · negociar · reclamar

&#x20;    Secretaria: validar usuários · confirmar/desmarcar reservas · avisos · relatórios

&#x20;       ↓

&#x20;  Confirmação da ação + notificação → Fim

5.6 Fluxo da fila de espera

Professor cancela → horário liberado

&#x20;  → sistema oferece ao 1º da fila (notificação)

&#x20;  → aceitou? Sim → reserva confirmada

&#x20;             Não / sem resposta no prazo → oferece ao próximo

&#x20;  → fila vazia → horário fica livre







6\. Organização da Equipe

Integrante	Responsabilidade principal	Apoio sugerido

Miguel	Back-end / API	Integração com o banco

Dante	Front-end (Flutter)	Protótipos

Isacar	Banco de dados	Testes da API

Dhyonatan	Documentação e apresentação





7\. Cronograma (12 semanas)

Semana	Atividade

1	Pesquisa de sistemas semelhantes e tecnologias

2	Levantamento e validação dos requisitos (com a secretaria)

3	Modelagem + wireframes

4	Criação do banco MySQL

5	Back-end: autenticação e cadastro

6	Módulo de reservas e fila de espera

7	Front-end: telas principais

8	Integração front + back

9	Testes e correções

10	Documentação final

11	Preparação da apresentação (ensaio)

12	Apresentação

8\. Ordem de Desenvolvimento

Banco de dados 2. Autenticação e login 3. Cadastro com validação 4. Reservas 5. Fila de espera 6. Avisos e solicitações 7. Reclamações 8. Relatórios 9. Ajustes de interface.

MVP (mínimo para apresentar): itens 1 a 5. Os demais entram se houver tempo.



9\. Testes

Checklist:



O sistema separa corretamente os perfis (professor × secretaria)?

Reservas são salvas e exibidas corretamente?

Dois usuários reservando o mesmo horário ao mesmo tempo: só um consegue?

A fila realoca a sala após um cancelamento?

As mensagens de erro são claras?

Os relatórios batem com os dados reais?

Tipos de teste: cadastro · login por perfil · reserva/cancelamento · fila · avisos e solicitações · relatórios · responsividade · segurança básica (acessar tela da secretaria como professor) · teste de aceitação com usuários reais (1 professor e 1 pessoa da secretaria).



10\. Documentação

Manual do usuário: cadastro, reserva/cancelamento, solicitações e reclamações, funcionamento da fila.

Manual técnico: tecnologias, estrutura de pastas, modelo do banco, instalação e configuração, endpoints da API.

Código: nomes claros e padronizados, comentários só onde necessário, pastas por módulo (autenticação, reservas, usuários, relatórios).

11\. Gestão de Riscos

Risco	Prob.	Impacto	Contingência

Falta de tempo	Alta	Alto	Priorizar o MVP (RF01 a RF09)

Integrante ausente	Média	Médio	Outro assume; documentação clara e Git atualizado

Dificuldade com Flutter/API/MySQL	Média	Alto	Tempo extra na semana de desenvolvimento, apoio da documentação oficial

Falha ou perda do banco	Baixa	Alto	Backups periódicos

Secretaria não aderir	Média	Alto	Simular o fluxo com dados fictícios; envolver a secretaria desde a semana 2

Senac não aprovar a Play Store	Média	Médio	Distribuir APK interno para demonstração

Servidor do Senac indisponível	Baixa	Médio	Ambiente local/nuvem gratuita para a demonstração

Vazamento de dados	Baixa	Alto	Hash de senha, HTTPS, LGPD

12\. Possíveis Perguntas da Banca (com respostas)

Sobre o problema e a ideia

1\. Por que essa solução é melhor do que a atual? Hoje a confirmação leva de dias a semanas e depende de conversa informal. Com o app, a disponibilidade é vista em tempo real, a reserva é registrada na hora e a secretaria deixa de controlar agenda manualmente.



2\. Por que um app e não uma planilha ou um grupo de WhatsApp? Planilha e grupo não impedem conflito de horário, não têm validação de usuários, não organizam fila nem geram relatórios. No app, as regras são automáticas e o histórico fica registrado.



3\. Já existe algo parecido? Existem sistemas genéricos de reserva de salas, mas nenhum conhecido focado no processo e na identidade do Senac, com fila de realocação e validação pela secretaria. Pesquisamos sistemas semelhantes para aproveitar as boas ideias e simplificar.



4\. Quem vai usar e quem ganha mais? Professores e secretaria usam diretamente. Os alunos ganham indiretamente, com aulas mais previsíveis na sala. Fica como evolução futura o acesso de consulta para alunos.



Sobre as funcionalidades

5\. Como funciona a fila de espera? Quando um professor cancela, o sistema oferece o horário ao primeiro da fila e o notifica. Se ele aceitar, a reserva é confirmada; se recusar ou não responder no prazo, passa ao próximo. Se a fila estiver vazia, o horário volta a ficar livre.



6\. Como vocês evitam dois professores reservando o mesmo horário? Em duas camadas: o back-end valida a disponibilidade e o banco tem uma restrição UNIQUE para sala + data + horário. Mesmo que dois pedidos cheguem juntos, apenas um é gravado.



7\. Por que a secretaria precisa validar o cadastro? Para garantir que só professores e funcionários reais do Senac acessem o sistema, evitando uso indevido da sala.



8\. Por que são exigidas 3 confirmações da secretaria? (responda conforme a decisão da equipe) Foi uma exigência do cenário para dar controle institucional. Reconhecemos o risco de atraso, por isso o número de confirmações é configurável: pode ser 1 ou 3, conforme a política do Senac.



9\. Como funciona a troca de horário entre professores? Um professor envia uma proposta por mensagem interna. Se o outro aceitar, o sistema atualiza as duas reservas e notifica a secretaria.



10\. O que o relatório mostra e para que serve? Frequência de reservas, cancelamentos e reclamações por período. Serve para a secretaria identificar horários mais disputados, problemas recorrentes na sala e planejar manutenção e recursos.



Sobre tecnologia

11\. Por que Flutter (ou Kotlin)? Flutter permite um único código para Android (e futuramente iOS), tem desenvolvimento rápido e é adequado ao prazo de 12 semanas.



12\. Por que o app não acessa o MySQL diretamente? Seria inseguro: exporia credenciais e permitiria acesso indevido. Por isso o app conversa com uma API, que valida login, aplica as regras e só ela acessa o banco.







