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

Overall running both tests in serial takes 2h-2h30<br>
To run both 'solo' and 'mini' tests in parallel, use their tag:
```bash
# FULL (not down-sampled) 'corriel' test for 'son' from 'HG002_trio' (takes ~ 3.5h):
pytest \
        --tag HG002_trio --tag son --tag full \
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
