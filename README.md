# Weather Forecast Ruby CLI ☀️

Pequena aplicação de linha de comando em **Ruby puro** que consulta a API pública da
[Open-Meteo](https://open-meteo.com/) e retorna a previsão de temperatura para uma
data e coordenadas informadas pelo usuário.

O foco deste projeto é demonstrar fundamentos de Ruby sem depender de framework:
consumo de API HTTP, parsing de JSON, validação de entrada, tratamento de erros,
organização de responsabilidades e testes automatizados.

## O Que Entrega

A CLI recebe:

- uma data no formato brasileiro `dd-mm-yyyy`
- latitude
- longitude
- opcionalmente, a flag `--hourly`

E retorna:

- temperatura mínima do dia
- temperatura máxima do dia
- temperatura média do dia
- temperaturas hora a hora, quando `--hourly` é informado

## Como Rodar

Pré-requisitos:

- Ruby `3.3.0` ou compatível
- Bundler

Instale as dependências:

```bash
bundle install
```

Execute informando `data`, `latitude` e `longitude`:

```bash
ruby bin/weather 15-07-2026 -20.4697 -54.6201
```

Para incluir a temperatura hora a hora:

```bash
ruby bin/weather 15-07-2026 -20.4697 -54.6201 --hourly
```

Observação: a Open-Meteo retorna uma janela limitada de previsão. Se a data
informada estiver fora do range retornado pela API, a aplicação informa esse erro
de forma explícita.

## Exemplo De Saída

```text
Weather forecast for 15-07-2026
Location: -20.4697, -54.6201
Timezone: America/Campo_Grande

Minimum temperature: 18.0 °C
Maximum temperature: 22.0 °C
Average temperature: 20.0 °C
```

Com `--hourly`:

```text
Hourly temperatures:
00:00 - 18.0 °C
01:00 - 20.0 °C
02:00 - 22.0 °C
```

## Decisões Técnicas

### Ruby puro, sem framework 🧰

A implementação usa bibliotecas padrão do Ruby:

- `net/http` para a chamada HTTP
- `json` para parsing da resposta
- `uri` para montar a query string
- `date` para validação e manipulação das datas

A única gem externa é `rspec`, usada exclusivamente para testes. Optei por
`Net::HTTP` em vez de Faraday/HTTParty porque o escopo pede uma chamada `GET`
simples, com timeout e tratamento de erro. Evitar uma dependência extra aqui deixa
o projeto mais direto e transparente para avaliação dos fundamentos.

### Responsabilidades separadas

O código não fica concentrado em um método grande. Ele foi dividido em camadas
pequenas, com fronteiras claras:

| Arquivo | Responsabilidade |
| --- | --- |
| `bin/weather` | Entrada CLI, saída padrão e códigos de erro |
| `lib/weather_app.rb` | Orquestra o fluxo principal da aplicação |
| `lib/input_validator.rb` | Valida data, latitude e longitude |
| `lib/net_http_client.rb` | Adaptador fino sobre `Net::HTTP` |
| `lib/weather_api_client.rb` | Monta a request, chama a API, trata status HTTP e faz JSON parse |
| `lib/weather_forecast.rb` | Valida o payload da API, filtra a data e calcula min/max/média |
| `lib/weather_presenter.rb` | Formata a resposta final para o usuário |
| `lib/errors.rb` | Centraliza erros de domínio da aplicação |

Essa separação também facilita os testes: a regra de negócio é testada sem depender
da rede, e o cliente da API pode receber um HTTP client fake por injeção de
dependência.

## Tratamento De Erros

A aplicação trata os cenários pedidos no teste:

- data em formato inválido
- data inexistente, como `31-02-2026`
- data fora do range retornado pela Open-Meteo
- latitude/longitude ausentes
- latitude/longitude não numéricas
- latitude fora de `-90..90`
- longitude fora de `-180..180`
- timeout, falha de rede ou API indisponível
- resposta HTTP não bem-sucedida
- JSON inválido
- payload da API em formato inesperado

Os erros são convertidos para mensagens orientadas ao usuário e códigos de saída
diferentes na CLI:

- `1`: erro de entrada
- `2`: erro de API/rede
- `3`: erro de previsão ou payload inesperado

## Testes Automatizados

Rode a suíte com:

```bash
bundle exec rspec
```

Ou, para visualizar os cenários:

```bash
bundle exec rspec --format documentation
```

A suíte cobre, entre outros pontos:

- caso de sucesso com data dentro do range
- listagem hora a hora
- data fora do range
- formato de data inválido
- coordenadas ausentes, inválidas ou fora do range
- falha na chamada HTTP
- status HTTP de erro
- JSON inválido
- payload inesperado da API

Os testes **não fazem chamada real para a Open-Meteo**. Eles usam fakes/stubs por
injeção de dependência, mantendo a suíte rápida, determinística e sem dependência
de disponibilidade externa.

## Checklist Dos Requisitos

| Requisito | Status |
| --- | --- |
| Receber data, latitude e longitude via linha de comando | ✅ |
| Usar formato de data `dd-mm-yyyy` | ✅ |
| Consultar Open-Meteo sem API key | ✅ |
| Exibir temperatura mínima, máxima e média | ✅ |
| Listar temperatura hora a hora opcionalmente | ✅ |
| Tratar data fora do range | ✅ |
| Tratar data inválida | ✅ |
| Tratar coordenadas inválidas | ✅ |
| Tratar falha de rede/API/timeout | ✅ |
| Tratar resposta inesperada da API | ✅ |
| Usar Ruby puro com `net/http` | ✅ |
| Fazer parsing com `json` | ✅ |
| Ter testes RSpec automatizados | ✅ |
| Separar responsabilidades do código | ✅ |

## Notas De Implementação

Alguns cuidados intencionais:

- a query string é montada com `URI.encode_www_form`, evitando concatenação manual
  de URL
- os timeouts são configurados no cliente da API
- a API é chamada com `timezone=auto`, permitindo que a Open-Meteo retorne horários
  coerentes com a localização consultada
- o range de previsão solicitado é de `16` dias para tornar explícito o horizonte
  esperado no teste
- erros externos são traduzidos para erros de domínio, mantendo a CLI simples

No geral, a ideia foi manter o projeto pequeno, mas com decisões que escalam bem:
fronteiras claras, testes determinísticos e tratamento explícito dos cenários que
normalmente quebram integrações com APIs. 🚀
