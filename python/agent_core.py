import subprocess

class AgentCore:
    def __init__(self, workspace_path="/Users/lopanapol/git-repo/sentium-pico"):
        self.workspace_path = workspace_path

    def run_fish_command(self, command):
        full_command = f'fish -c "{command}"'
        process = subprocess.Popen(full_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, cwd=self.workspace_path)
        stdout, stderr = process.communicate()
        return stdout.decode('utf-8').strip(), stderr.decode('utf-8').strip()

    def process_command(self, command):
        stdout, stderr = self.run_fish_command(f'source system/perception/api.fish && api_process "{command}"')
        if stderr:
            return f"Error: {stderr}"
        return stdout
