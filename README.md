# Weather Forecast Ruby CLI

Small Ruby CLI application that fetches weather forecast data from the public Open-Meteo API and returns temperature information for a specific date and location.

The application receives:

- date in Brazilian format: `dd-mm-yyyy`
- latitude
- longitude

It returns:

- minimum temperature
- maximum temperature
- average temperature
- optionally, hourly temperatures for the selected day

## Requirements

- Ruby
- Bundler

The Ruby version used in development is defined in `.ruby-version`.

## Installation

Clone the repository and install dependencies:

```bash
bundle install