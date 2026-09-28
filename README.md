# SheetSage2 on Intel Arc Pro B70

Run the SheetSage2 model on Linux with an Intel GPU using either a local Python
environment or Docker Compose. The model snapshot is stored separately from
this repository.

## Requirements

- A Linux host with a working Intel GPU driver and `/dev/dri` device access.
- The SheetSage2 model snapshot at
  `/srv/data/models/music/sheetsage2/SheetSage2`.
- The snapshot must contain `config.json`, `model.safetensors`, and `infer.py`.

There is no separate `pip install sheetsage2` package; inference runs from the
model snapshot's `infer.py`. SheetSage2 may download its MERT-v2-FullSong parent
model on the first run if it is not already in the Hugging Face cache.

## Download the model from Hugging Face

The scripts expect the `m-a-p/SheetSage2` repository at
`/srv/data/models/music/sheetsage2/SheetSage2`. Download the complete snapshot
with Hugging Face's CLI:

```bash
python3 -m venv .venv-hf-download
. .venv-hf-download/bin/activate
python -m pip install huggingface_hub
hf download m-a-p/SheetSage2 \
  --local-dir /srv/data/models/music/sheetsage2/SheetSage2
deactivate
```

The downloaded directory should contain `config.json`, `model.safetensors`,
and `infer.py`. The CLI is documented in the [Hugging Face download guide](https://huggingface.co/docs/huggingface_hub/en/guides/cli), and the files come from the [SheetSage2 model repository](https://huggingface.co/m-a-p/SheetSage2).

SheetSage2 uses `m-a-p/MERT-v2-FullSong` as its parent model. Transformers
downloads the configured parent revision into the Hugging Face cache on first
inference; the Compose setup persists that cache in its `huggingface-cache`
volume. See the [MERT-v2-FullSong repository](https://huggingface.co/m-a-p/MERT-v2-FullSong).

Both Hugging Face model repositories list their model license as CC BY-NC 4.0.
Review the license terms on the model pages before use.

## Run with Docker Compose

The supplied Compose file mounts the model directory read-only at
`/models/SheetSage2`, mounts `./input` at `/input`, writes results to
`./output`, and persists the Hugging Face cache in a named volume. If your
model snapshot is elsewhere, update the model volume in `compose.yaml`.

Build the image:

```bash
docker compose build
```

Place audio files in `input/`, then run inference:

```bash
docker compose run --rm sheetsage2 /input/heavy.mp3
```

The Docker entrypoint supplies the model path, `xpu` device, `bf16` dtype,
score rendering, and audio rendering. Results go to `/output` inside the
container, which is `./output` on the host. You can choose another output
directory and pass additional `infer.py` options:

```bash
docker compose run --rm sheetsage2 /input/song.mp3 /output/song --melody-only
```

To read audio from a different host directory, set `INPUT_DIR`:

```bash
INPUT_DIR=/path/to/audio docker compose run --rm sheetsage2 /input/song.mp3
```

Docker must be able to pass `/dev/dri` into the container. To check GPU
visibility on the host, run:

```bash
ls -l /dev/dri
xpu-smi discovery
```

## Troubleshooting

The Docker entrypoint clears `LD_LIBRARY_PATH` before starting PyTorch because
the XPU wheel bundles its matched oneAPI runtime. Host oneAPI libraries can
override it with incompatible `libur_loader.so` or `libsycl.so` versions.

If inference cannot use the GPU, confirm that `/dev/dri` exists on the host and
that Docker can pass it into the container. `xpu-smi discovery` can help check
host visibility; PyTorch inference itself is the final check that the runtime
can use the device.
