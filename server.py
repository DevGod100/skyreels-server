from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from skyreels_v2_infer.pipelines.diffusion_forcing_pipeline import DiffusionForcingPipeline

# Initialize once at import time
pipeline = DiffusionForcingPipeline(
    "Skywork/SkyReels-V2-DF-14B-540P",
    dit_path="/app/SkyReels-V2"
)

app = FastAPI()

class Payload(BaseModel):
    prompt: str
    image_url: str

@app.post("/generate-video")
async def generate_video(data: Payload):
    try:
        result = pipeline(
            prompt=data.prompt,
            image=data.image_url,
            base_num_frames=97,
            num_frames=257,
            overlap_history=17,
            addnoise_condition=20,
            offload=True,
            teacache=True
        )
        video_path = result.get("video_path") or result.get("video")
        if not video_path:
            raise RuntimeError("No video path returned")
        return {"video_url": video_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))