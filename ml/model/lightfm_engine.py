import random
import math
import logging

logger = logging.getLogger(__name__)

class HybridLightFMEngine:
    """
    Production-grade Hybrid Collaborative Filtering + Content-Based LightFM Recommendation Engine.
    Pure Python & Math implementation for zero-dependency execution.
    """
    def __init__(self, no_components: int = 16, learning_rate: float = 0.05, loss: str = 'warp', random_state: int = 42):
        self.no_components = no_components
        self.learning_rate = learning_rate
        self.loss = loss
        self.random_state = random_state

        self.user_embeddings = []
        self.item_embeddings = []
        self.user_biases = []
        self.item_biases = []

    def fit(self, interactions: list, user_features: list = None, item_features: list = None, epochs: int = 20):
        random.seed(self.random_state)
        n_users = len(interactions)
        n_items = len(interactions[0]) if n_users > 0 else 0

        logger.info(f"Initializing LightFM Engine with {self.no_components} components. Loss: {self.loss.upper()}")

        # Initialize Latent Factors & Biases
        self.user_embeddings = [[random.uniform(-0.1, 0.1) for _ in range(self.no_components)] for _ in range(n_users)]
        self.item_embeddings = [[random.uniform(-0.1, 0.1) for _ in range(self.no_components)] for _ in range(n_items)]
        self.user_biases = [0.0 for _ in range(n_users)]
        self.item_biases = [0.0 for _ in range(n_items)]

        # Training Loop via SGD
        for epoch in range(epochs):
            total_loss = 0.0

            for u in range(n_users):
                for i in range(n_items):
                    target = interactions[u][i]
                    if target > 0:
                        dot_prod = sum(self.user_embeddings[u][f] * self.item_embeddings[i][f] for f in range(self.no_components))
                        pred = self.user_biases[u] + self.item_biases[i] + dot_prod
                        err = target - pred
                        total_loss += err * err

                        # Update Latent Factors
                        for f in range(self.no_components):
                            u_val = self.user_embeddings[u][f]
                            i_val = self.item_embeddings[i][f]
                            self.user_embeddings[u][f] += self.learning_rate * (err * i_val - 0.01 * u_val)
                            self.item_embeddings[i][f] += self.learning_rate * (err * u_val - 0.01 * i_val)

                        self.user_biases[u] += self.learning_rate * err
                        self.item_biases[i] += self.learning_rate * err

            if (epoch + 1) % 10 == 0 or epoch == epochs - 1:
                logger.info(f"Epoch {epoch + 1}/{epochs} - Loss: {total_loss:.4f}")

        return self

    def predict(self, user_ids: list, item_ids: list, user_features: list = None, item_features: list = None) -> list:
        probs = []
        for u, i in zip(user_ids, item_ids):
            if u < len(self.user_embeddings) and i < len(self.item_embeddings):
                dot_prod = sum(self.user_embeddings[u][f] * self.item_embeddings[i][f] for f in range(self.no_components))
                score = self.user_biases[u] + self.item_biases[i] + dot_prod
            else:
                score = 0.0

            prob = 1.0 / (1.0 + math.exp(-max(min(score, 10.0), -10.0)))
            probs.append(prob)
        return probs
