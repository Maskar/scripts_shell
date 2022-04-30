#!/usr/bin/env bash

function jpn() {screen -dmS JLab conda run -n depaul jupyter-notebook --autoreload --port=8889 --port-retries=0 --browser='open -a Microsoft\ Edge %s' $@}
#function jpl() {screen -dmS JLab conda run -n depaul jupyter-lab --browser='open -a JupyterLab --args %s' $@}
function jpl() {screen -dmS JLab conda run -n depaul jupyter-lab --autoreload --port=8888 --port-retries=0 --browser='open -a JupyterLab %s' $@}

function jp() {conda run -n depaul jupyter $@}

function get_ip_orange() {curl -s -u dc075e55-726d-43e9-f251-faadb9c3a27d:x -X GET https://www.getflix.com.au/api/v1/addresses.json | jq --raw-output '.[].ip_address'}
#function tedata_ip() {echo 41.39.89.232}
#function tedata_ip() {echo 197.51.236.127}
function get_ip_tedata() {curl -s -u 787ea028-6bb5-4ade-d2db-53585e02d6ce:x -X GET https://www.getflix.com.au/api/v1/addresses.json | jq --raw-output '.[].ip_address'}
#function get_ip_tedata() {echo 197.50.65.2}

function get_ip_public() {curl checkip.amazonaws.com}
