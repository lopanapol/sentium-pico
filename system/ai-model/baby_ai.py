import json
import os
import sys
import re
import random
from baby_brain import BabyBrain

class BabyAILearner:
    def __init__(self, knowledge_file="baby_ai_knowledge.json", learning_rate=0.1):
        self.script_dir = os.path.dirname(__file__)
        self.knowledge_file = os.path.join(self.script_dir, knowledge_file)
        self.learning_rate = learning_rate
        self.knowledge = self._load_knowledge()
        self.baby_brain = BabyBrain() # Initialize BabyBrain

    def _load_knowledge(self):
        if os.path.exists(self.knowledge_file):
            with open(self.knowledge_file, 'r') as f:
                return json.load(f)
        return {}

    def _save_knowledge(self):
        with open(self.knowledge_file, 'w') as f:
            json.dump(self.knowledge, f, indent=4)

    def predict_sentiment(self, word):
        word_lower = word.lower()
        score = self.knowledge.get(word_lower, 0.0)

        if score > 0.2:
            return "positive"
        elif score < -0.2:
            return "negative"
        else:
            return "neutral"

    def learn_from_feedback(self, word, predicted_sentiment, actual_sentiment):
        word_lower = word.lower()
        current_score = self.knowledge.get(word_lower, 0.0)

        if predicted_sentiment == actual_sentiment:
            if actual_sentiment == "positive":
                self.knowledge[word_lower] = min(1.0, current_score + self.learning_rate / 2)
            elif actual_sentiment == "negative":
                self.knowledge[word_lower] = max(-1.0, current_score - self.learning_rate / 2)
        else:
            if actual_sentiment == "positive":
                self.knowledge[word_lower] = min(1.0, current_score + self.learning_rate)
            elif actual_sentiment == "negative":
                self.knowledge[word_lower] = max(-1.0, current_score - self.learning_rate)
            elif actual_sentiment == "neutral":
                if predicted_sentiment == "positive":
                    self.knowledge[word_lower] = max(-1.0, current_score - self.learning_rate)
                elif predicted_sentiment == "negative":
                    self.knowledge[word_lower] = min(1.0, current_score + self.learning_rate)

        self._save_knowledge()
        self.baby_brain.learn_from_word(word_lower) # Teach the baby brain

    def auto_learn_from_text(self, text_content, assumed_sentiment):
        words = re.findall(r'\b\w+\b', text_content.lower())
        learned_words = {}
        for word in words:
            predicted = self.predict_sentiment(word)
            self.learn_from_feedback(word, predicted, assumed_sentiment)
            learned_words[word] = self.knowledge.get(word, 0.0) # Store the updated score
        return learned_words


if __name__ == "__main__":
    baby_ai = BabyAILearner()

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "predict":
            if len(sys.argv) > 2:
                word = sys.argv[2]
                sentiment = baby_ai.predict_sentiment(word)
                baby_response = baby_ai.baby_brain.generate_vocalization(sentiment)
                print(json.dumps({"word": word, "sentiment": sentiment, "babyResponse": baby_response}))
            else:
                print(json.dumps({"error": "Missing word for prediction"}))
        elif command == "learn":
            if len(sys.argv) > 4:
                word = sys.argv[2]
                predicted_sentiment = sys.argv[3]
                actual_sentiment = sys.argv[4]
                baby_ai.learn_from_feedback(word, predicted_sentiment, actual_sentiment)
                print(json.dumps({"success": True, "word": word}))
            else:
                print(json.dumps({"error": "Missing arguments for learning"}))
        elif command == "auto-learn-content":
            if len(sys.argv) > 3:
                content = sys.argv[2]
                assumed_sentiment = sys.argv[3]
                learned_words = baby_ai.auto_learn_from_text(content, assumed_sentiment)
                print(json.dumps({"success": True, "message": "Auto-learning from content complete", "learned_words": learned_words}))
            else:
                print(json.dumps({"error": "Missing content or assumed sentiment for auto-learn-content"}))
        else:
            print(json.dumps({"error": "Unknown command"}))
    else:
        while True:
            word_input = input("\nEnter a word (or 'q' to quit): ").strip()
            if word_input.lower() == 'q':
                break

            if not word_input:
                continue

            predicted_sentiment = baby_ai.predict_sentiment(word_input)
            baby_response = baby_ai.baby_brain.generate_vocalization(predicted_sentiment)

            print(f"Baby AI: {baby_response}")
            baby_ai.baby_brain.learn_from_word(word_input) # Baby learns from the word it hears

        print("\n--- Session End ---")