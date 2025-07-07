
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


Later, go to the folder "package_to_zip" and package all the dependencies and zip it:
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


Keep in mind that thanks to the null_resource block, we can insert the Postgres Schema and dummy data when `terraform apply`:
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