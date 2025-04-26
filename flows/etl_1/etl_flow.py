from prefect import flow, task, get_run_logger
import logging


@task
def hello():
    logger = get_run_logger()
    logger.info("hello")

@task
def world():
    logger = get_run_logger()
    logger.info("world!")

@flow(name="second-etl-flow")
def etl():
    hello()
    world()
    

if __name__ == "__main__":
    etl()