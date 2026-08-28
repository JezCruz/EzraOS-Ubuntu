#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

BASE = Path.home() / "EzraOS"
CONFIG_FILE = BASE / "config" / "ezra.conf"
NAME_FILE = BASE / "data" / "user_name.txt"
HISTORY_DIR = BASE / "data" / "history"

BLUE = "\033[1;34m"
CYAN = "\033[1;36m"
WHITE = "\033[1;37m"
GRAY = "\033[0;37m"
RED = "\033[1;31m"
RESET = "\033[0m"


def clean_config_value(value: str) -> str:
    value = value.strip()

    if (
        len(value) >= 2
        and value[0] == value[-1]
        and value[0] in {"'", '"'}
    ):
        return value[1:-1]

    return value


def load_config() -> dict[str, str]:
    config: dict[str, str] = {}

    for raw_line in CONFIG_FILE.read_text().splitlines():
        line = raw_line.strip()

        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        config[key.strip()] = clean_config_value(value)

    return config


def get_user_name() -> str:
    if not NAME_FILE.exists():
        return "User"

    name = NAME_FILE.read_text().strip()
    return name or "User"


def create_modes(name: str) -> dict[str, dict[str, str]]:
    return {
        "general": {
            "label": "General Chat",
            "greeting": (
                f"Hello, {name}. General Chat Mode is ready.\n"
                "Ask me about everyday questions, explanations, writing, "
                "planning, and general learning."
            ),
            "system": (
                f"You are Ezra, the personal offline assistant of {name}. "
                "Reply clearly and concisely. Use simple English or natural "
                "Taglish when helpful. Never invent Tagalog words. "
                "Admit uncertainty instead of making up information."
            ),
        },
        "java": {
            "label": "Java Programming",
            "greeting": (
                f"Hello, {name}. Java Programming Mode is ready.\n"
                "Ask me about Java syntax, variables, loops, OOP, debugging, "
                "projects, and practice exercises."
            ),
            "system": (
                f"You are Ezra, {name}'s patient Java tutor. "
                "Teach one concept at a time. Use correct and runnable Java "
                "examples. Explain important lines in simple English or "
                "natural Taglish. Avoid unnecessarily long answers."
            ),
        },
        "python": {
            "label": "Python Programming",
            "greeting": (
                f"Hello, {name}. Python Programming Mode is ready.\n"
                "Ask me about Python basics, functions, data structures, "
                "debugging, scripts, and practice exercises."
            ),
            "system": (
                f"You are Ezra, {name}'s Python tutor. "
                "Use runnable beginner-friendly examples. Explain errors "
                "clearly and suggest safe fixes."
            ),
        },
        "sql": {
            "label": "SQL Learning",
            "greeting": (
                f"Hello, {name}. SQL Learning Mode is ready.\n"
                "Ask me about queries, tables, joins, filtering, databases, "
                "and SQL practice."
            ),
            "system": (
                f"You are Ezra, {name}'s SQL tutor. "
                "Use practical tables, queries, and expected results. "
                "Mention dialect differences when relevant."
            ),
        },
        "git": {
            "label": "Git and GitHub",
            "greeting": (
                f"Hello, {name}. Git and GitHub Mode is ready.\n"
                "Ask me about commits, branches, pushing, pulling, merging, "
                "and fixing Git errors."
            ),
            "system": (
                f"You are Ezra, {name}'s Git assistant. "
                "Give safe commands and explain what each command changes. "
                "Warn before destructive commands."
            ),
        },
        "linux": {
            "label": "Linux and Ubuntu",
            "greeting": (
                f"Hello, {name}. Linux and Ubuntu Mode is ready.\n"
                "Ask me about commands, packages, files, permissions, scripts, "
                "services, networking, and Ubuntu setup."
            ),
            "system": (
                f"You are Ezra, {name}'s Linux and Ubuntu assistant. "
                "Prefer commands compatible with Ubuntu and Debian-based Linux. "
                "Use apt for package management when appropriate. "
                "Explain shell commands clearly and warn before destructive commands. "
                "Consider permissions, paths, services, networking, Git, SSH, "
                "processes, and system administration. "
                "Do not suggest Android or Termux-specific commands unless explicitly requested."
            ),
        },
        "bible": {
            "label": "Bible Study",
            "greeting": (
                f"Hello, {name}. Bible Study Mode is ready.\n"
                "Ask me about Scripture, biblical context, Christian faith, "
                "devotion, and personal application."
            ),
            "system": (
                f"You are Ezra, {name}'s careful Bible study assistant. "
                "Separate Bible text, explanation, historical context, and "
                "personal application. Never fabricate exact verse wording. "
                "When exact wording is uncertain, say so. Clearly identify "
                "the Bible translation when known. Do not claim infallibility."
            ),
        },
    }


def history_file(mode: str) -> Path:
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)
    return HISTORY_DIR / f"{mode}.json"


def load_history(mode: str) -> list[dict[str, str]]:
    path = history_file(mode)

    if not path.exists():
        return []

    try:
        data = json.loads(path.read_text())
    except (json.JSONDecodeError, OSError):
        return []

    if not isinstance(data, list):
        return []

    valid: list[dict[str, str]] = []

    for item in data:
        if not isinstance(item, dict):
            continue

        role = item.get("role")
        content = item.get("content")

        if role in {"user", "assistant"} and isinstance(content, str):
            valid.append({"role": role, "content": content})

    return valid


def save_history(
    mode: str,
    messages: list[dict[str, str]],
) -> None:
    history_file(mode).write_text(
        json.dumps(messages, ensure_ascii=False, indent=2)
    )


def trim_history(
    messages: list[dict[str, str]],
    max_chars: int = 3200,
) -> list[dict[str, str]]:
    kept: list[dict[str, str]] = []
    total = 0

    for message in reversed(messages):
        content = str(message.get("content", ""))
        size = len(content)

        if kept and total + size > max_chars:
            break

        kept.append(message)
        total += size

    kept.reverse()

    while kept and kept[0].get("role") == "assistant":
        kept.pop(0)

    return kept


def stream_request(
    url: str,
    payload: dict[str, Any],
) -> str:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Accept": "text/event-stream",
        },
        method="POST",
    )

    pieces: list[str] = []
    started = False

    with urllib.request.urlopen(request, timeout=300) as response:
        for raw_line in response:
            line = raw_line.decode(
                "utf-8",
                errors="replace",
            ).strip()

            if not line.startswith("data:"):
                continue

            data = line[5:].strip()

            if data == "[DONE]":
                break

            try:
                event = json.loads(data)
            except json.JSONDecodeError:
                continue

            choices = event.get("choices", [])

            if not choices:
                continue

            delta = choices[0].get("delta", {})
            content = delta.get("content")

            if not isinstance(content, str) or not content:
                continue

            if not started:
                print(" " * 50, end="\r")
                print(f"{BLUE}Ezra >{RESET} ", end="", flush=True)
                started = True

            pieces.append(content)

            # Streaming output already arrives in small pieces.
            # A tiny delay gives it a natural typing appearance.
            for character in content:
                print(character, end="", flush=True)
                time.sleep(0.004)

    if started:
        print()

    return "".join(pieces).strip()


def request_answer(
    config: dict[str, str],
    mode_data: dict[str, str],
    history: list[dict[str, str]],
    user_text: str,
) -> tuple[str, list[dict[str, str]]]:
    working_history = trim_history(history)

    messages = [
        {"role": "system", "content": mode_data["system"]},
        *working_history,
        {"role": "user", "content": user_text},
    ]

    payload: dict[str, Any] = {
        "model": config.get("MODEL_NAME", "Ezra"),
        "messages": messages,
        "temperature": 0.4,
        "top_p": 0.85,
        "repeat_penalty": 1.15,
        "max_tokens": int(config.get("MAX_TOKENS", "256")),
        "stream": True,
    }

    endpoint = (
        f"http://{config.get('HOST', '127.0.0.1')}:"
        f"{config.get('PORT', '8080')}/v1/chat/completions"
    )

    try:
        answer = stream_request(endpoint, payload)
    except urllib.error.HTTPError as error:
        body = error.read().decode(
            "utf-8",
            errors="replace",
        )

        # Retry once with no previous history when context is full.
        if error.code == 400:
            messages = [
                {"role": "system", "content": mode_data["system"]},
                {"role": "user", "content": user_text},
            ]

            payload["messages"] = messages
            working_history = []
            answer = stream_request(endpoint, payload)
        else:
            raise RuntimeError(
                f"Server error {error.code}: {body[:300]}"
            ) from error

    if not answer:
        raise RuntimeError("The server returned an empty response.")

    new_history = [
        *working_history,
        {"role": "user", "content": user_text},
        {"role": "assistant", "content": answer},
    ]

    return answer, trim_history(new_history)


def print_header(
    mode_data: dict[str, str],
    model_name: str,
) -> None:
    print(f"{BLUE}EZRA AI{RESET}")
    print()
    print(f"{WHITE}{mode_data['greeting']}{RESET}")
    print(f"{BLUE}Mode{RESET}   : {CYAN}{mode_data['label']}{RESET}")
    print(f"{BLUE}Model{RESET}  : {CYAN}{model_name}{RESET}")
    print(f"{BLUE}Status{RESET} : {CYAN}Ready{RESET}")
    print(f"{BLUE}{'-' * 46}{RESET}")
    print()
    print(
        f"{GRAY}Commands: /new  /history  /help  /exit{RESET}"
    )
    print()


def main() -> int:
    user_name = get_user_name()
    modes = create_modes(user_name)

    mode = (
        sys.argv[1].lower()
        if len(sys.argv) > 1
        else "general"
    )

    if mode not in modes:
        print(f"{RED}Unknown mode: {mode}{RESET}")
        return 1

    config = load_config()
    mode_data = modes[mode]
    history = load_history(mode)

    print_header(
        mode_data,
        config.get("MODEL_NAME", "Ezra"),
    )

    while True:
        try:
            user_text = input(
                f"{CYAN}You > {RESET}"
            ).strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if not user_text:
            continue

        command = user_text.lower()

        if command == "/exit":
            break

        if command in {"/new", "/clear"}:
            history = []
            save_history(mode, history)
            print(f"{GRAY}Conversation cleared.{RESET}")
            print()
            continue

        if command == "/help":
            print()
            print("/new      Start a new conversation")
            print("/history  Show saved conversation")
            print("/exit     Return to EzraOS")
            print()
            continue

        if command == "/history":
            if not history:
                print(f"{GRAY}No saved conversation yet.{RESET}")
                print()
                continue

            print()

            for message in history:
                label = (
                    "You"
                    if message["role"] == "user"
                    else "Ezra"
                )

                print(
                    f"{BLUE}{label}:{RESET} "
                    f"{message['content']}"
                )
                print()

            continue

        print(
            f"{GRAY}Ezra is thinking...{RESET}",
            end="\r",
            flush=True,
        )

        try:
            _, history = request_answer(
                config,
                mode_data,
                history,
                user_text,
            )
        except (
            urllib.error.URLError,
            TimeoutError,
            RuntimeError,
        ) as error:
            print(" " * 50, end="\r")
            print(f"{RED}Error: {error}{RESET}")
            print(
                f"{GRAY}Open Settings and restart "
                f"the AI server.{RESET}"
            )
            print()
            continue

        save_history(mode, history)
        print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
