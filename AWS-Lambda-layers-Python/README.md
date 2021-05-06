Steps:
- Download `.whl` files from repos such as Pypi.org
- Extract contents to an empty directory named `python`
- Zip the python folder to `python.zip`
- Run command in bash `aws lambda publish-layer-version --layer-name python-<REPLACE_LIBRARY_NAME_HERE> --description "<REPLACE_DESCRIPTION_HERE>" --compatible-runtimes python3.6 python3.7 python3.8 --zip-file fileb://python.zip`

References:
- https://wahlnetwork.com/2020/07/28/how-to-create-aws-lambda-layers-for-python/
