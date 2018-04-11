#!/bin/bash

for i in {1..64}
do
	curl -u admin:admin -H "Accept: application/json" -X DELETE --noproxy 10.0.0.10 -i http://10.0.0.10/sessionInformation/$i/remove
done
