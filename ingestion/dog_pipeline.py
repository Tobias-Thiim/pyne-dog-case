# ingestion/dog_pipeline.py

import os
import logging
import requests
import dlt

DOG_URL = "https://api.thedogapi.com/v1/breeds"

logger = logging.getLogger(__name__)


@dlt.source
def dog_source():
    resp = requests.get(DOG_URL, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    # The API returns a list of breed dicts. dlt.resource can take this list.
    yield dlt.resource(data, name="dog_breeds")


def run_pipeline(dataset: str | None = None) -> None:
    # Default to the RAW_DATASET env var, else "bronze"
    dataset = dataset or os.environ.get("RAW_DATASET", "bronze")

    pipeline = dlt.pipeline(
        pipeline_name="dog_pipeline",
        destination="bigquery",
        dataset_name=dataset,
    )

    try:
        load_info = pipeline.run(
            dog_source(),
            table_name="dog_api_raw",
        )
        logger.info("Dog pipeline completed successfully", extra={"dataset": dataset})
        # valgfrit: behold print til lokal debugging
        print(load_info)
        return load_info

    except Exception:
        # Vigtigt: ERROR log + re-raise → job bliver markeres som FAILED i Cloud Run/Functions
        logger.error(
            "Dog pipeline failed",
            exc_info=True,
            extra={"dataset": dataset},
        )
        raise


if __name__ == "__main__":
    # For lokal kørsel, så du kan se logs i konsollen
    logging.basicConfig(level=logging.INFO)
    run_pipeline()
