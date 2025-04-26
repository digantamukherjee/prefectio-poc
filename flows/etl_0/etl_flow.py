from prefect import flow, task

@task
def extract():
    return ["apple", "banana", "cherry"]

@task
def transform(data):
    return [item.upper() for item in data]

@task
def load(data):
    for item in data:
        print(f"Loading: {item}")

@flow(name="demo-etl-flow")
def etl():
    data = extract()
    transformed = transform(data)
    load(transformed)

if __name__ == "__main__":
    etl()
