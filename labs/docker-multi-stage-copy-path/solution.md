### The Issue
The final Docker stage is copying the built artifact from the wrong path. The builder creates `/out/app.txt`, but the final stage tries to copy `/out/app.tx`.

### Step-by-Step Fix

1. **Inspect the Dockerfile**:
   Read the multi-stage build and confirm the artifact name in the builder stage.

2. **Correct the `COPY` source path**:
   Update the final stage so it copies `/out/app.txt` into the runtime image.

3. **Rebuild the image**:
   Build the image again and make sure the Docker build completes without errors.

4. **Run the container**:
   Start the built image and confirm it prints `BrokenOps multi-stage build`.

5. **Verify the fix**:
   Once the build and run both succeed, the lab is solved.
