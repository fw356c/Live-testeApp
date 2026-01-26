## Teste 1 – Docker

Para a construção da imagem Docker da aplicação, optei por utilizar a imagem base node:alpine, por ser uma distribuição leve e segura.

Além disso, foi utilizada a abordagem de multi-stage build, separando a etapa de instalação das dependências da etapa de execução. Essa estratégia permite reduzir o tamanho da imagem final, eliminando arquivos desnecessários como cache do gerenciador de pacotes e ferramentas de build, resultando menor e mais eficiente.

## Teste 2 – Kubernetes
Separei essa parte em outro repositório (https://github.com/fw356c/Live-testeGitOps.git) seguinto bos praticas de GitOps, permitindo que ferramentas como ArgoCD efetuem a sicronização de estado do cluster de forma automatica partindo das alterações no repositório de infraestrutura.

## Teste 3 - CI/CD

O pipeline de CI/CD foi implementado com GitHub Actions. Ele executa testes automatizados, realiza o build da imagem Docker e publica a imagem no Docker Hub utilizando uma tag baseada no commit SHA. O deploy segue o modelo GitOps: após o build, o pipeline atualiza o manifesto Kubernetes no repositório de infraestrutura, que é monitorado pelo ArgoCD, responsável por sincronizar automaticamente o estado desejado da aplicação no cluster.

## Teste 4 - Banco de dados

Para o provisionamento de um banco de dados MySQL no AWS RDS, é possível utilizar diferentes abordagens, como a criação manual via console, uso da AWS CLI ou ferramentas de Infrastructure as Code, como Terraform. Em ambientes produtivos, a utilização de IaC é recomendada por garantir reprodutibilidade e controle de mudanças.

O banco de dados deve ser provisionado em subnets privadas, sem exposição direta à internet, permitindo acesso apenas a recursos confiáveis dentro da VPC, como aplicações ou clusters Kubernetes. Caso seja necessário acesso administrativo ao banco, pode-se utilizar uma VPN site-to-site entre a infraestrutura da empresa e a AWS, ou um Bastion Host para acesso controlado.

Em relação à segurança, o acesso ao RDS deve ser restrito por meio de Security Groups, liberando apenas as portas necessárias e apenas para origens autorizadas. As credenciais do banco devem ser armazenadas de forma segura, preferencialmente utilizando o AWS Secrets Manager, cofre externo ou alguma ferramenta de PAM. 

Para garantir disponibilidade e proteção dos dados, é recomendável habilitar backups automáticos. A política de retenção deve variar de acordo com a criticidade da aplicação, podendo incluir snapshots diários e, em cenários mais críticos, a utilização de configurações Multi-AZ para maior resiliência.

Após o Deploy do RDS (levando em conta que se trata de um MySQL) podemos usar comandos simples para validar o funcionamento como:

 - SELECT 1;
 - SHOW DATABASES;
 - SHOW GLOBAL STATUS LIKE 'Uptime';
 - SHOW ENGINE INNODB STATUS;

## Teste 5 – Resolução de Problemas

Considerando que o banco de dados apresenta uso excessivo de CPU e memória, a primeira ação seria analisar as requisições que estão chegando ao banco para entender a origem do consumo elevado de recursos. Isso inclui a verificação de queries lentas, possíveis locks ou aumento anormal no número de conexões ativas.

Em paralelo, seria feita a análise das métricas e logs da aplicação no CloudWatch, validando a ocorrência de erros 5xx, latência das requisições e identificando se houve aumento repentino de tráfego ou até mesmo um possível ataque à API. Também é fundamental revisar as alterações realizadas no último deploy para identificar se o problema está relacionado a mudanças recentes no código ou na configuração da aplicação.

Após a validação desses pontos iniciais, no curto prazo, medidas de mitigação podem ser adotadas para garantir a disponibilidade do serviço, como o escalonamento temporário dos recursos da API e do banco de dados. Idealmente, a infraestrutura deve contar com autoscaling baseado em métricas como uso de CPU e memória. Outras ações incluem a limitação de conexões simultâneas ao banco e, se necessário, a desativação temporária de funcionalidades que estejam gerando alto consumo de recursos.


## Teste 6 – Arquitetura e Escalabilidade

Diagrama:

        Usuários
           |
        Application Load Balancer (ALB)
           |
        Amazon EKS (Kubernetes)
           |
        Node.js API (Pods)  ← Auto Scaling (HPA)
           |
        Amazon RDS MySQL (Subnet Privada)

A aplicação é executada em uma arquitetura baseada em serviços gerenciados da AWS, priorizando alta disponibilidade, escalabilidade e segurança. O tráfego dos usuários é direcionado para um Application Load Balancer (ALB), responsável pelo balanceamento de carga das requisições HTTP e pela distribuição do tráfego entre as instâncias da aplicação.

A aplicação Node.js é executada em um cluster Kubernetes (Amazon EKS), onde cada instância da aplicação roda em containers organizados em pods. A escalabilidade da aplicação é garantida por meio do Horizontal Pod Autoscaler (HPA), que ajusta automaticamente a quantidade de pods com base em métricas como uso de CPU e memória. Em conjunto, o cluster conta com auto scaling dos nós (EC2), garantindo capacidade de infraestrutura suficiente para acomodar os pods criados pelo HPA.

O monitoramento e a centralização de logs são realizados utilizando o Amazon CloudWatch, permitindo visibilidade sobre métricas de desempenho, erros da aplicação e utilização de recursos. Alertas podem ser configurados para detectar comportamentos anômalos e permitir atuação proativa em incidentes.

O banco de dados é provisionado utilizando Amazon RDS MySQL, executando em subnets privadas, sem exposição direta à internet. O acesso é restrito por meio de Security Groups, com backups automáticos habilitados e possibilidade de configuração Multi-AZ para maior resiliência. As credenciais de acesso ao banco são armazenadas de forma segura no AWS Secrets Manager.