
# Python Part:
In the python module we generate the zip file for AWS Lambda that includes the needed pip packages and the latest python code.

For Zip file Lambda version:
first create `venv`:
```
python3 -m venv venv
source venv/bin/activate
```

Once activated the venv, install dependencies from requirements.txt inside your venv:
pip install -r requirements.txt


Later, package all the dependencies and zip it:
```
pip install --target package_to_zip -r requirements.txt
cp index.py package_to_zip/
cd package_to_zip
zip -r ../../terraform/lambda.zip .
cd ..
```

After the zip file is located inside the `Terraform folder`, disable the `venv` using:
```
deactivate
```


## Issues with psycopg2 library for Postgres not working with AWS Lambda:
In our local machine, do not download psycopg2 using PIP!

Instead, you must download it from the Jkehler repository below, and `COPY-PASTE` the psycopg2-3.9 directory into your AWS Lambda project in `python/package_to_zip` Folder, and **rename it** to `psycopg2`. After that is donde, you can zip the package with the instructions in the section above.

Get the psycopg2-3.9 folder from https://github.com/jkehler/awslambda-psycopg2/tree/master/psycopg2-3.9



# Terraform Part:
After the zip file is located inside the `Terraform folder`, you can run the AWS Infrastructure using:
```
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

And to destroy:
```
terraform destroy -var-file="dev.tfvars"
```


# Testing deployed Lambda
To test the API CALL, use this URL structure: https://`<AWS-URL>`?apikey=`<APIKEY>`&t=titanic

For example, the URL will look like: `https://ogpgg6.execute-api.eu-central-1.amazonaws.com/dev/resource?apikey=1234567&t=titanic`



# RDS

To see the whole list of available PostgresDBs use this command and scroll down to see the whole list:
```
aws rds describe-db-engine-versions \
  --engine postgres \
  --region eu-central-1 \
  --query "DBEngineVersions[].EngineVersion"
```


Keep in mind in the past we used the `null_resource` block to insert automatically the Postgres Schema and dummy data when `terraform apply`:
```
resource "null_resource" "cluster" {
  depends_on = [aws_db_instance.education]

  # The trigger detects when a new DB Host URL changes, so it will apply this new Schema to the new DB:
  triggers = {
    db_endpoint = aws_db_instance.education.address
    schema_hash  = filemd5("../db/init_schema.sql")
  }

  provisioner "local-exec" {
    command = "psql -h ${aws_db_instance.education.address} -p ${aws_db_instance.education.port}  -U ${var.db_user} -d ${var.db_name} -f ../db/init_schema.sql"
    environment = {
      PGPASSWORD = var.postgres_password
    }
  }
}
```

But now, we create the Schema and inject dummy data using Api_gateway using the POST call to the path `/init` as detailed below.


# Comments about Temporal Testing AWS Services all together:
To test we use the Lambda python script called: `lambda_python_manualTest.py`.
Currently Lambda and RDS are in public vpc for testing purposes, so in order to test Lambda can use the values from Secrets Manager we have to comment temporaly in order to avoid the timeout issue due to the VPC netowrking reason:

```
vpc_config {
  subnet_ids         = var.rds_public_subnets
  security_group_ids = [var.rds_sg_id]
}
```

After this is working, I will continue update the connection with Api Gateway.


# API Gateway:
1.-There are two methods for GET and POST available in PATH "/resource":

For GET calls, just use the `api_gateway_url` terraform output in the web browser, after this you will see the 5 latest values from the DB.


For POST calls, just push values using this example command:
```
curl -X POST <api_gateway_URL TERRAFORM OUTPUT>/dev/resource \
  -H "Content-Type: application/json" \
  -d '{"name": "Joe", "favorite_movie": "The Matrix"}'
```

2.-There are only one method for POST available in PATH "/init" used to create the DB Schema and inject dummy data in the PostgresDB:

For the POST call, in any console just execute this command only 1 time at the beginning before injecting individual rows to the DB:
```
curl -i -X POST "api_gateway_URL TERRAFORM OUTPUT>/dev/init"
```