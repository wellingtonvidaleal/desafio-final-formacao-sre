# DESAFIO FINAL DA FORMAÇÃO SRE ELVEN WORKS - 3ª TURMA

Esse projeto trata-se do Desafio Final do aluno Wellington Vida Leal, da 3ª turma da Formação SRE da Elven Works.

## Funcionalidades

- Stack do Wordpress multi AZ, elástica e escalável.
- Monitoramento e observabilidade do Wordpress via Prometheus e Grafana.

## Como executar o projeto

Ao baixar o projeto, entre no diretorio "route53-zone" e execute os seguintes comandos:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

A execução desse projeto terraform gera como outputs os name servers da zona de DNS primária que devem ser cadastrados no registro.br.

Após o cadastro dos name servers, volte na raiz do projeto e execute os seguintes comando:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

Pronto, o Wordpress e seu monitoramento estarão funcionando!