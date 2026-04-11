import { aiRepository } from '../repository/AiRepository';
import { AiGenerateRecipeResponse } from '../model/AiGenerateRecipeResponse';

type SessionListener = () => void;

interface SessionListenerEntry {
  id: number;
  listener: SessionListener;
}

export interface ChatMessage {
  id: string;
  role: 'ai' | 'user';
  content: string;
  time: string;
  recipes?: AiGenerateRecipeResponse[];
}

export interface AICocktailSessionSnapshot {
  inputText: string;
  isLoading: boolean;
  errorMessage: string;
  lastDurationLabel: string;
  lastRecipeCount: number;
  messageList: ChatMessage[];
}

const INITIAL_MESSAGE_LIST: ChatMessage[] = [
  {
    id: 'm1',
    role: 'ai',
    content: '你好，我是 AI 调酒助手。直接输入口味、基酒、场景或预算，我会调用真实接口生成配方。',
    time: '20:36'
  }
];

const INITIAL_SNAPSHOT: AICocktailSessionSnapshot = {
  inputText: '',
  isLoading: false,
  errorMessage: '',
  lastDurationLabel: '--',
  lastRecipeCount: 0,
  messageList: INITIAL_MESSAGE_LIST
};

class AICocktailSessionStore {
  private snapshot: AICocktailSessionSnapshot = this.cloneSnapshot(INITIAL_SNAPSHOT);
  private listeners: SessionListenerEntry[] = [];
  private nextListenerId: number = 1;
  addListener(listener: SessionListener): number {
    const listenerId: number = this.nextListenerId;
    this.nextListenerId += 1;
    this.listeners = this.listeners.concat([{ id: listenerId, listener }]);
    return listenerId;
  }

  removeListener(listenerId: number): void {
    this.listeners = this.listeners.filter((entry: SessionListenerEntry): boolean => entry.id !== listenerId);
  }

  getSnapshot(): AICocktailSessionSnapshot {
    return this.cloneSnapshot(this.snapshot);
  }
  setInputText(text: string): void {
    if (this.snapshot.inputText === text) {
      return;
    }
    this.snapshot = {
      inputText: text,
      isLoading: this.snapshot.isLoading,
      errorMessage: this.snapshot.errorMessage,
      lastDurationLabel: this.snapshot.lastDurationLabel,
      lastRecipeCount: this.snapshot.lastRecipeCount,
      messageList: this.snapshot.messageList
    };
    this.notifyListeners();
  }
  setErrorMessage(message: string): void {
    if (this.snapshot.errorMessage === message) {
      return;
    }
    this.snapshot = {
      inputText: this.snapshot.inputText,
      isLoading: this.snapshot.isLoading,
      errorMessage: message,
      lastDurationLabel: this.snapshot.lastDurationLabel,
      lastRecipeCount: this.snapshot.lastRecipeCount,
      messageList: this.snapshot.messageList
    };
    this.notifyListeners();
  }

  async submitPrompt(prompt: string): Promise<void> {
    const trimmedPrompt: string = prompt.trim();
    if (trimmedPrompt.length === 0 || this.snapshot.isLoading) {
      return;
    }

    const currentTime: string = this.getCurrentTimeText();
    const pendingMessageId: string = this.createMessageId('ai');
    const nextMessageList: ChatMessage[] = [
      ...this.snapshot.messageList,
      {
        id: this.createMessageId('user'),
        role: 'user',
        content: trimmedPrompt,
        time: currentTime
      },
      {
        id: pendingMessageId,
        role: 'ai',
        content: '正在请求 AI 生成真实配方，请稍候...',
        time: currentTime
      }
    ];
    this.snapshot = {
      inputText: '',
      isLoading: true,
      errorMessage: '',
      lastDurationLabel: this.snapshot.lastDurationLabel,
      lastRecipeCount: this.snapshot.lastRecipeCount,
      messageList: nextMessageList
    };
    this.notifyListeners();

    const startTime: number = Date.now();
    try {
      const recipes: AiGenerateRecipeResponse[] = await aiRepository.generateRecipeByText({ prompt: trimmedPrompt });
      const durationMs: number = Date.now() - startTime;
      this.snapshot = {
        inputText: this.snapshot.inputText,
        isLoading: false,
        errorMessage: this.snapshot.errorMessage,
        lastDurationLabel: `${Math.max(1, Math.round(durationMs / 1000))}s`,
        lastRecipeCount: recipes.length,
        messageList: this.replaceMessage(this.snapshot.messageList, pendingMessageId, {
          id: pendingMessageId,
          role: 'ai',
          content: this.buildRecipeSummary(recipes),
          time: this.getCurrentTimeText(),
          recipes
        })
      };
      this.notifyListeners();
    } catch (error) {
      const message: string = this.resolveErrorMessage(error);
      this.snapshot = {
        inputText: this.snapshot.inputText,
        isLoading: false,
        errorMessage: message,
        lastDurationLabel: '--',
        lastRecipeCount: 0,
        messageList: this.replaceMessage(this.snapshot.messageList, pendingMessageId, {
          id: pendingMessageId,
          role: 'ai',
          content: `生成失败：${message}`,
          time: this.getCurrentTimeText()
        })
      };
      this.notifyListeners();
    }
  }

  private notifyListeners(): void {
    const currentListeners: SessionListenerEntry[] = [...this.listeners];
    currentListeners.forEach((entry: SessionListenerEntry): void => {
      entry.listener();
    });
  }

  private buildRecipeSummary(recipes: AiGenerateRecipeResponse[]): string {
    if (recipes.length === 0) {
      return '本次没有生成到可展示的配方，请稍后重试。';
    }
    return `已为你生成 ${recipes.length} 份配方，可继续追问口味微调、替换基酒或减少材料。`;
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string = '生成配方失败'): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }
    return fallbackMessage;
  }

  private createMessageId(prefix: string): string {
    return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
  }

  private getCurrentTimeText(): string {
    const now: Date = new Date();
    const hour: string = `${now.getHours()}`.padStart(2, '0');
    const minute: string = `${now.getMinutes()}`.padStart(2, '0');
    return `${hour}:${minute}`;
  }

  private replaceMessage(messages: ChatMessage[], messageId: string, nextMessage: ChatMessage): ChatMessage[] {
    return messages.map((message: ChatMessage): ChatMessage => {
      if (message.id === messageId) {
        return nextMessage;
      }
      return message;
    });
  }

  private cloneSnapshot(snapshot: AICocktailSessionSnapshot): AICocktailSessionSnapshot {
    return {
      inputText: snapshot.inputText,
      isLoading: snapshot.isLoading,
      errorMessage: snapshot.errorMessage,
      lastDurationLabel: snapshot.lastDurationLabel,
      lastRecipeCount: snapshot.lastRecipeCount,
      messageList: this.cloneMessageList(snapshot.messageList)
    };
  }

  private cloneMessageList(messages: ChatMessage[]): ChatMessage[] {
    return messages.map((message: ChatMessage): ChatMessage => {
      return {
        id: message.id,
        role: message.role,
        content: message.content,
        time: message.time,
        recipes: this.cloneRecipes(message.recipes)
      };
    });
  }

  private cloneRecipes(recipes?: AiGenerateRecipeResponse[]): AiGenerateRecipeResponse[] | undefined {
    if (!recipes) {
      return undefined;
    }

    return recipes.map((recipe: AiGenerateRecipeResponse): AiGenerateRecipeResponse => {
      return {
        name: recipe.name,
        description: recipe.description,
        materials: [...recipe.materials],
        steps: [...recipe.steps]
      };
    });
  }
}

export const aiCocktailSessionStore: AICocktailSessionStore = new AICocktailSessionStore();
