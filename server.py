# skyreels-server/server.py
from fastapi import FastAPI
from pydantic   import BaseModel
import skyreels_v2_infer as infer  # the V2 inference module

app = FastAPI()

class Payload(BaseModel):
    prompt: str
    image_url: str

@app.post("/generate-video")
async def generate_video(data: Payload):
    # call the V2 image-to-video function
    video_path = infer.generate_video_df(
        model_id="Skywork/SkyReels-V2-DF-14B-540P",
        resolution="540P",
        base_num_frames=97,
        num_frames=257,
        overlap_history=17,
        prompt=data.prompt,
        image=data.image_url,
        addnoise_condition=20,
        offload=True,
        teacache=True
    )
    return {"video_url": video_path}