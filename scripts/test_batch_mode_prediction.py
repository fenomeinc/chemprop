import unittest, os
import batch_mode_prediction as target
from click.testing import CliRunner
import pandas as pd
from tempfile import NamedTemporaryFile

## Update this to point to any real fitted Chemprop model.
## This one is pulled from s3://py65/models/chemprop/20200402/
CHEMPROP_TEST_MODEL = "~/NES/chemprop/fl65/models/0/fold_0/model_0/model.pt"
CHEMPROP_PREDICT_PATH = "../predict.py"

CHEMPROP_TEST_MODEL = os.path.normpath(CHEMPROP_TEST_MODEL)
CHEMPROP_PREDICT_PATH = os.path.normpath(CHEMPROP_PREDICT_PATH)

class TestBMPBasicFunctionality(unittest.TestCase):
    def setUp(self):
        self.runner = CliRunner()
        self.simple_in_df = pd.DataFrame({
                'smiles': ['COC1=C(C=CC(=C1)C=O)O', 
                           'Cn1cnc2c1c(=O)[nH]c(=O)n2C']
            })
        self.simple_in_file = NamedTemporaryFile()
        self.simple_in_df.to_csv(self.simple_in_file.name, index=False)
        self.test_out_file = NamedTemporaryFile()
    
    def test_run_chemprop(self):
        """Test that Chemprop will run given a trivial input
        """
        result = self.runner.invoke(target, args=[
            '--input_file', self.simple_in_file.name,
            '--chemprop_model_path', CHEMPROP_TEST_MODEL,
            '--output_file', self.test_out_file,
            '--chemprop_predict_path', CHEMPROP_PREDICT_PATH    ,
            '--no_filter_proteins'
            ], catch_exceptions=False)
        self.assertTrue(result.exit_code == 0)
        out_df = pd.read_csv(self.test_out_file.name)
        self.assertTrue(len(out_df) > 2)
    
    def test_prediction_repeatability(self):
        """Test that we get the same result if we run the model
        multiple times.
        """
        pass

if __name__ == '__main__':
    unittest.main()
