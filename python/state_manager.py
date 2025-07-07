import redis
import json

class StateManager:
    def __init__(self, redis_host='localhost', redis_port=6379):
        self.redis = redis.Redis(host=redis_host, port=redis_port, db=0, decode_responses=True)

    def get_state(self, key):
        return self.redis.hgetall(key)

    def update_state(self, key, state):
        self.redis.hmset(key, state)

    def get_version(self):
        return self.redis.get('sentium:version')

    def set_version(self, version):
        self.redis.set('sentium:version', version)
