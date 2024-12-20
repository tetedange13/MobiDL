## Testing

### Requirements

- [Pytest-workflow](https://github.com/LUMC/pytest-workflow)

<br>

### Run tests

```bash
pytest \
	--keep-workflow-wd \
	--verbose \
	--git-aware \
	--basetemp=/scratch \
	tests/
```
Due to `--keep-workflow-wd` option, dirs `Name_of_my_test` present at `--basetemp` path (created by `pytest-workflow`) must be be deleted *manually* afterwards

```bash
# FULL (not down-sampled) 'corriel' test for 'son' from 'HG002_trio' (takes ~ 3.5h):
pytest \
        --tag HG002_trio --tag son --tag full \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# Down-sampled (chr22 only) 'corriel' test for 'son' from 'HG002_trio' (takes ~ XX):
pytest \
        --tag HG002_trio --tag son --tag downsampled \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# Down-sampled (chr22 only) 'patient' test (takes ~ XX):
pytest \
        --tag patient --tag downsampled \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# Full (but small) 'patient' test (takes ~ 15 min):
pytest \
        --tag patient --tag full \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# HG38 full (but small) 'patient' test (takes ~ 15 min):
pytest \
        --tag patient --tag full --tag hg38 \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# NEAT-simulated exome data, with UMAI variants:
pytest \
        --tag simulated --tag exome \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &

# NEAT-simulated panel data (MAI_19_genes), with UMAI variants:
pytest \
        --tag simulated --tag panel \
        --keep-workflow-wd \
        --verbose \
        --git-aware \
        --basetemp=/scratch \
        tests/test_panelCapture.yaml &
```


<br>

### Dir organization

`test_a_workflow.yaml` files for each tested workflow or sub-workflow are directly under `tests` sub-dir<br>
Test data for each workflow are expected to be under `tests/workflow_name`
