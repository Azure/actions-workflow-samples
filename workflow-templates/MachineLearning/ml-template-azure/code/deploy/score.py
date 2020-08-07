import os
import joblib
import numpy as np
import argparse

from sklearn.svm import SVC
from azureml.core import Model
from azureml.monitoring import ModelDataCollector
from inference_schema.schema_decorators import input_schema, output_schema
from inference_schema.parameter_types.numpy_parameter_type import NumpyParameterType
from inference_schema.parameter_types.standard_py_parameter_type import StandardPythonParameterType


# The init() method is called once, when the web service starts up.
# Typically you would deserialize the model file, as shown here using joblib,
# and store it in a global variable so your run() method can access it later.
def init():
    global model
    global inputs_dc, prediction_dc
    # The AZUREML_MODEL_DIR environment variable indicates
    # a directory containing the model file you registered.
    model_file_name = "model.pkl"
    model_path = os.path.join(os.environ.get("AZUREML_MODEL_DIR"), model_file_name)
    model = joblib.load(model_path)
    inputs_dc = ModelDataCollector("sample-model", designation="inputs", feature_names=["feat1", "feat2", "feat3", "feat4"])
    prediction_dc = ModelDataCollector("sample-model", designation="predictions", feature_names=["prediction"])


# The run() method is called each time a request is made to the scoring API.
# Shown here are the optional input_schema and output_schema decorators
# from the inference-schema pip package. Using these decorators on your
# run() method parses and validates the incoming payload against
# the example input you provide here. This will also generate a Swagger
# API document for your web service.
@input_schema('data', NumpyParameterType(np.array([[0.1, 1.2, 2.3, 3.4]])))
@output_schema(StandardPythonParameterType({'predict': [['Iris-virginica']]}))
def run(data):
    # Use the model object loaded by init().
    result = model.predict(data)
    inputs_dc.collect(data) #this call is saving our input data into Azure Blob
    prediction_dc.collect(result) #this call is saving our input data into Azure Blob

    # You can return any JSON-serializable object.
    return { "predict": result.tolist() }
