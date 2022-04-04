#! /bin/bash

pip3 install mysql-connector-python
sudo yum install -y jq

echo "export TEST1DBUSER=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test1\" --query 'SecretString' --output text | jq -r '.\"username\"'\`" >> ~/.bashrc
echo "export TEST1PORT=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test1\" --query 'SecretString' --output text | jq -r '.\"port\"'\`" >> ~/.bashrc
echo "export TEST1DB=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test1\" --query 'SecretString' --output text | jq -r '.\"dbname\"'\`" >> ~/.bashrc
echo "export TEST1HOST=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test1\" --query 'SecretString' --output text | jq -r '.\"host\"'\`" >> ~/.bashrc
echo "export TEST1DBPASSWORD=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test1\" --query 'SecretString' --output text | jq -r '.\"password\"'\`" >> ~/.bashrc

if [ "$1" == "all" ]; then
    echo "export TEST2DBUSER=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test2\" --query 'SecretString' --output text | jq -r '.\"username\"'\`" >> ~/.bashrc
    echo "export TEST2PORT=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test2\" --query 'SecretString' --output text | jq -r '.\"port\"'\`" >> ~/.bashrc
    echo "export TEST2DB=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test2\" --query 'SecretString' --output text | jq -r '.\"dbname\"'\`" >> ~/.bashrc
    echo "export TEST2HOST=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test2\" --query 'SecretString' --output text | jq -r '.\"host\"'\`" >> ~/.bashrc
    echo "export TEST2DBPASSWORD=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test2\" --query 'SecretString' --output text | jq -r '.\"password\"'\`" >> ~/.bashrc

    echo "export TEST3DBUSER=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test3\" --query 'SecretString' --output text | jq -r '.\"username\"'\`" >> ~/.bashrc
    echo "export TEST3PORT=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test3\" --query 'SecretString' --output text | jq -r '.\"port\"'\`" >> ~/.bashrc
    echo "export TEST3DB=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test3\" --query 'SecretString' --output text | jq -r '.\"dbname\"'\`" >> ~/.bashrc
    echo "export TEST3HOST=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test3\" --query 'SecretString' --output text | jq -r '.\"host\"'\`" >> ~/.bashrc
    echo "export TEST3DBPASSWORD=\`aws secretsmanager get-secret-value  --secret-id \"/devopsgurudemo/dbsecret-test3\" --query 'SecretString' --output text | jq -r '.\"password\"'\`" >> ~/.bashrc
fi

echo "The setup is successfully completed."